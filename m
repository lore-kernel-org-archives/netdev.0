From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: sock_get_timestamp() ktime_to_timeval returns -2?
Date: Sat, 05 Apr 2008 14:38:31 +0200
Message-ID: <47F772C7.6020700@cosmosbay.com>
References: <013101c89683$1bd00940$0a00a8c0@Andrew>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060809020002040004020002"
Cc: netdev@vger.kernel.org
To: Andrew Brampton <andrew@bramp.freeserve.co.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:40527
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751725AbYDEMif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 08:38:35 -0400
In-Reply-To: <013101c89683$1bd00940$0a00a8c0@Andrew>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060809020002040004020002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Andrew Brampton a écrit :
> Hi,
> I'm using the following piece of code to record the received time of my 
> packets.
> 
> struct timeval tv = {0,0};
> if ( ioctl(s, SIOCGSTAMP, &tv) )
>   return 0;
> 
> When I use UDP this is all great, but when I use TCP this stops working. 
> I have since found out that I can't use this for TCP packets[1], but the 
> reason I'm writing this email is because ioctl returns zero when using 
> TCP and tv has a odd value in it. tv.tv_sec = -2, and tv.tv_usec = 999999.
> 
> Now I assume -2 is some kind of error code, so I dug into the linux code 
> to try and figure out what it means. The ioctl eventually calls 
> sock_get_timestamp() which in turn calls ktime_to_timeval. I can see in 
> sock_get_timestamp() that tv_sec is compared to -1 and ioctl returns an 
> error, however I can not find where tv_sec is set to -2. If -2 is 
> another error code then it should be checked inside sock_get_timestamp().
> 
> So I'm wondering if this is a bug in the kernel somewhere, or should I 
> just expect ioctl to fail yet return 0? I have not included a test app, 
> but if you want I'll be happy to code a short app to show this problem, 
> but the critital lines are the ioctl call and that a TCP socket is used. 
> This occurs on both the 2.6.22-3-amd64 kernel as well as on 2.6.24.



I believe the following patch should make sure ENOENT is delivered to the 
application. And yes, SIOCGSTAMP has a meaning only for UDP or other packet 
protocols.

Thank you Andrew for spotting this bug.

[SOCK] sk_stamp: should be initialized to ktime_set(-1L, 0)

Problem spotted by Andrew Brampton

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------060809020002040004020002
Content-Type: text/plain;
 name="sk_stamp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk_stamp.patch"

diff --git a/net/core/sock.c b/net/core/sock.c
index 2654c14..7a0567b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1725,7 +1725,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
-	sk->sk_stamp = ktime_set(-1L, -1L);
+	sk->sk_stamp = ktime_set(-1L, 0);
 
 	atomic_set(&sk->sk_refcnt, 1);
 	atomic_set(&sk->sk_drops, 0);

--------------060809020002040004020002--
