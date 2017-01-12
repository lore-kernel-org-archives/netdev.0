From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 13:36:30 -0800
Message-ID: <1484256990.13165.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1c39bf41-4ebf-643a-c6a0-caf98a17a89c@oracle.com>
         <20170112.154143.1940764507974590907.davem@davemloft.net>
         <131ec7b7-5b74-2545-8bf7-92812443a876@oracle.com>
         <20170112.161852.1469407145449781531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@oracle.com, rob.gardner@oracle.com,
        netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170112.161852.1469407145449781531.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-12 at 16:18 -0500, David Miller wrote:
> From: Shannon Nelson <shannon.nelson@oracle.com>
> Date: Thu, 12 Jan 2017 12:56:08 -0800
> 
> > 
> > 
> > On 1/12/2017 12:41 PM, David Miller wrote:
> >> From: Shannon Nelson <shannon.nelson@oracle.com>
> >> Date: Thu, 12 Jan 2017 12:30:38 -0800
> >>
> >>> On 1/12/2017 12:25 PM, Eric Dumazet wrote:
> >>>> On Thu, 2017-01-12 at 13:15 -0700, Rob Gardner wrote:
> >>>>
> >>>>>
> >>>>> I suspect that someplace, somebody is casting val to an int * or
> >>>>> something like that.
> >>>>
> >>>> Then that would be the bug. Can we root cause this please ?
> >>>>
> >>>>
> >>>
> >>> Look in net/ipv4/tcp_fastopen.c:tcp_fastopen_cookie_gen() for the line
> >>>
> >>> 	 struct in6_addr *buf = (struct in6_addr *) tmp.val;
> >>
> >> Oh yeah, that's it.  I didn't notice that at all.
> >>
> > 
> > It looked to me like swapping the data fields would be the easiest and
> > least impactive way to fix this.  I didn't want to mess with the
> > logic. I'm certainly open to other suggestions.
> 
> Given the nature of the problem, your fix is probably fine.
> 
> Eric, any objections?

I am still objecting to this fix.

gcc makes no provision for aligning an variable that has alignof() = 1

We had such issues in the past.

We need the proper annotation on ->val field itself, to get proper
alignment.

Then moving around the other field is a matter of avoiding a hole.

val should be an union, so that proper alignment is enforced by one
member.

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fc5848dad7a43216b3f124c4afdaa6b64b23910c..5b790abf4c16313c9110996683be3a7fb368b66f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -62,8 +62,13 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 
 /* TCP Fast Open Cookie as stored in memory */
 struct tcp_fastopen_cookie {
+       union {
+               u8      val[TCP_FASTOPEN_COOKIE_MAX];
+#if IS_ENABLED(CONFIG_IPV6)
+               struct in6_addr addr;
+#endif
+       };
        s8      len;
-       u8      val[TCP_FASTOPEN_COOKIE_MAX];
        bool    exp;    /* In RFC6994 experimental option format */
 };
 


