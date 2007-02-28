From: John <linux.kernel@free.fr>
Subject: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 11:18:54 +0100
Message-ID: <45E5570E.7050301@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux.kernel@free.fr
To: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I know it's possible to have Linux timestamp incoming datagrams as soon 
as they are received, then for one to retrieve this timestamp later with 
an ioctl command or a recvmsg call.

As far as I understand, one can either do

   const int on = 1;
   setsockopt(sock, SOL_SOCKET, SO_TIMESTAMP, &on, sizeof on);

then use recvmsg()

or not set the SO_TIMESTAMP socket option and just call

   ioctl(sock, SIOCGSTAMP, &tv);

after each datagram has been received.

SIOCGSTAMP
     Return a struct timeval with the receive timestamp of the last
packet passed to the user. This is useful for accurate round trip time
measurements. See setitimer(2) for a description of struct timeval.


As far as I understand, this timestamp is given by the CLOCK_REALTIME 
clock. However, I would like to obtain a timestamp given by the 
CLOCK_MONOTONIC clock.

Relevant parts of the code (I think):

net/core/dev.c

void net_enable_timestamp(void)
{
   atomic_inc(&netstamp_needed);
}

void __net_timestamp(struct sk_buff *skb)
{
   struct timeval tv;

   do_gettimeofday(&tv);
   skb_set_timestamp(skb, &tv);
}

static inline void net_timestamp(struct sk_buff *skb)
{
   if (atomic_read(&netstamp_needed))
     __net_timestamp(skb);
   else {
     skb->tstamp.off_sec = 0;
     skb->tstamp.off_usec = 0;
   }
}

do_gettimeofday() just calls __get_realtime_clock_ts()

Would it be possible to replace do_gettimeofday() by ktime_get_ts() with 
the appropriate division by 1000 to convert the struct timespec back 
into a struct timeval?

void __net_timestamp(struct sk_buff *skb)
{
   struct timespec now;
   struct timeval tv;

   ktime_get_ts(&ts);
   tv.tv_sec = now.tv_sec;
   tv->tv_usec = now.tv_nsec/1000;
   skb_set_timestamp(skb, &tv);
}

How many apps / drivers would this break?

Is there perhaps a different way to achieve this?

Regards.

