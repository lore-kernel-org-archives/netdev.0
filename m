From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: [PATCH v2 1/2] net: enable high resolution timer mode to timeout datagram sockets
Date: Wed, 23 Aug 2017 00:10:26 +0000
Message-ID: <1503447027-44399-2-git-send-email-vallish@amazon.com>
References: <1503447027-44399-1-git-send-email-vallish@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eduval@amazon.com>, <anchalag@amazon.com>, <vallish@amazon.com>
To: <davem@davemloft.net>, <shuah@kernel.org>,
        <richardcochran@gmail.com>, <xiyou.wangcong@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503447027-44399-1-git-send-email-vallish@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable high resolution timer mode to time SO_RCVTIMEO value used with
setsockopt(2) on AF_UNIX and AF_INET datagram sockets. By default,
SO_RCVTIMEO uses low resolution timer which is good for most of socket
use cases.

Background:
Kernel timer wheel was refactored in 4.8 to avoid drawbacks with previous
implementation:
https://lwn.net/Articles/691064/
Unlike the previous "kernel timer wheel" implementation in 4.4 which aimed
for accuracy by paying cost for cascading tracked timers at the boundary of
256 jiffies, the new timer wheel implementation gets rid of cascading
latency by paying a price for being less accurate for far off timers.

Use Case:
New implementation is good for most of socket use cases. However we have a
use case where our application is sensitive to socket timeout including
long timeouts.  Please refer to test code as part of this patch series.
One of the test runs with a timeout value of 180 seconds timed out at
190 seconds.
[root@]# ./datagram_sock_timeout 180000
datagram_sock_timeout failed: took 190.00 seconds
[root@]#
The same program when run on a 4.4 kernel would timeout more acurately and
the kernel added slack was not noticeable to user application.

Interesting text:
a) Standards for setsockopt:
http://pubs.opengroup.org/onlinepubs/009695399/functions/setsockopt.html
<snip>
SO_RCVTIMEO
Sets the timeout value that specifies the maximum amount of time an input
function waits until it completes. It accepts a timeval structure with the
number of seconds and microseconds specifying the limit on how long to wait
for an input operation to complete. If a receive operation has blocked for
this much time without receiving additional data, it shall return with a
partial count or errno set to [EAGAIN] or [EWOULDBLOCK] if no data is
received. The default for this option is zero, which indicates that a
receive operation shall not time out. This option takes a timeval
structure. Note that not all implementations allow this option to be set.
<end snip>
This only talks about the maximum time and the current behavior indeed
follows this standard. System call does not return before the time
specified and it does return EAGAIN.
b) Man page for SETSOCKOPT(3P):
<snip>
The  option_name  argument  specifies  a  single  option to set. It can be
one of the socket-level options defined in <sys_socket.h> and described in
Section 2.10.16, Use of Options.  If option_name is equal to SO_RCVTIMEO
or SO_SNDTIMEO and the implementation supports setting the option, it is
unspecified whether the struct timeval  pointed  to by  option_value  is
stored  as  provided by this function or is rounded up to align with the
resolution of the clock being used. If setsockopt() is called with
option_name equal to SO_ACCEPTCONN, SO_ERROR, or SO_TYPE, the behavior is
unspecified.
<end snip>
Behavior is unspecified.
3) Man page for SELECT(2):
<snip>
Note  that  the  timeout  interval  will  be  rounded up to the system
clock granularity, and kernel scheduling delays mean that the blocking
interval may overrun by a small amount.  If both fields of the timeval
structure are zero, then select() returns immediately.  (This is useful
for polling.)  If timeout is NULL (no timeout),  select()  can block
indefinitely.
<end snip>
Select system call guarantees timeout interval and inturn uses highres
timer.

Reported-by: Manjula Peiris <thelgep@amazon.com>
Reviewed-by: Eduardo Valentin <eduval@amazon.com>
Reviewed-by: Anchal Agarwal <anchalag@amazon.com>
Signed-off-by: Vallish Vaidyeshwara <vallish@amazon.com>
---
 net/core/datagram.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee5647b..832c147 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -80,6 +80,7 @@ static int receiver_wake_function(wait_queue_entry_t *wait, unsigned int mode, i
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, key);
 }
+
 /*
  * Wait for the last received packet to be different from skb
  */
@@ -87,6 +88,9 @@ int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 				const struct sk_buff *skb)
 {
 	int error;
+	ktime_t expires;
+	struct timespec64 time;
+	unsigned long pre_sched_time;
 	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
 
 	prepare_to_wait_exclusive(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
@@ -116,7 +120,15 @@ int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 		goto interrupted;
 
 	error = 0;
-	*timeo_p = schedule_timeout(*timeo_p);
+	/* Wait using highres timer */
+	time.tv_sec = *timeo_p / HZ;
+	time.tv_nsec = jiffies_to_nsecs(*timeo_p % HZ);
+	expires = ktime_add_safe(ktime_get(), timespec64_to_ktime(time));
+	pre_sched_time = jiffies;
+	if (schedule_hrtimeout(&expires, HRTIMER_MODE_ABS))
+		*timeo_p = jiffies - pre_sched_time;
+	else
+		*timeo_p = 0;
 out:
 	finish_wait(sk_sleep(sk), &wait);
 	return error;
-- 
2.7.3.AMZN
