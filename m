From: Hannes Eder <heder@google.com>
Subject: Re: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Wed, 30 Sep 2009 15:38:12 +0200
Message-ID: <4AC35F44.60707@google.com>
References: <20090930131109.2b3f71b8@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754497AbZI3NiS@vger.kernel.org>
In-Reply-To: <20090930131109.2b3f71b8@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[cc: +Simon Horman]

Arjan van de Ven wrote:
 > From 761a182f96b3707e1fee44e1079ba227e48745d1 Mon Sep 17 00:00:00 2001
 > From: Arjan van de Ven <arjan@linux.intel.com>
 > Date: Wed, 30 Sep 2009 13:05:51 +0200
 > Subject: [PATCH] ipvs: Add boundary check on ioctl arguments
 >
 > The ipvs code has a nifty system for doing the size of ioctl command copies;
 > it defines an array with values into which it indexes the cmd to find the
 > right length.
 >
 > Unfortunately, the ipvs code forgot to check if the cmd was in the range
 > that the array provides, allowing for an index outside of the array,
 > which then gives a "garbage" result into the length, which then gets
 > used for copying into a stack buffer.
 >
 > Fix this by adding sanity checks on these as well as the copy size.
 >
 > Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
 > ---
 >  net/netfilter/ipvs/ip_vs_ctl.c |   14 +++++++++++++-
 >  1 files changed, 13 insertions(+), 1 deletions(-)
 >
 > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
 > index ac624e5..3c52796 100644
 > --- a/net/netfilter/ipvs/ip_vs_ctl.c
 > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
 > @@ -2077,6 +2077,10 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user 
*user, unsigned int len)
 >  	if (!capable(CAP_NET_ADMIN))
 >  		return -EPERM;
 >
 > +	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX + 1)
 > +		return -EINVAL;
 > +	if (len < 0 || len >  MAX_ARG_LEN)
 > +		return -EINVAL;
 >  	if (len != set_arglen[SET_CMDID(cmd)]) {
 >  		pr_err("set_ctl: len %u != %u\n",
 >  		       len, set_arglen[SET_CMDID(cmd)]);
 > @@ -2353,17 +2357,25 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user 
*user, int *len)
 >  {
 >  	unsigned char arg[128];

can MAX_ARG_LEN be used here?

 >  	int ret = 0;
 > +	unsigned int copylen;
 >
 >  	if (!capable(CAP_NET_ADMIN))
 >  		return -EPERM;
 >
 > +	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX + 1)
 > +		return -EINVAL;
 > +
 >  	if (*len < get_arglen[GET_CMDID(cmd)]) {
 >  		pr_err("get_ctl: len %u < %u\n",
 >  		       *len, get_arglen[GET_CMDID(cmd)]);
 >  		return -EINVAL;
 >  	}
 >
 > -	if (copy_from_user(arg, user, get_arglen[GET_CMDID(cmd)]) != 0)
 > +	copylen = get_arglen[GET_CMDID(cmd)];
 > +	if (copylen > 128)

I think it's better to use 'copylen > sizeof(arg)' here.

 > +		return -EINVAL;
 > +
 > +	if (copy_from_user(arg, user, copylen) != 0)
 >  		return -EFAULT;
 >
 >  	if (mutex_lock_interruptible(&__ip_vs_mutex))
