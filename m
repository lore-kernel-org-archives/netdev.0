From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: loading sctp when load sctp_probe
Date: Mon, 16 Dec 2013 10:04:26 -0500
Message-ID: <20131216150426.GC19809@hmsreliant.think-freely.org>
References: <52AA783A.7090502@huawei.com>
 <20131213122605.GA23384@hmsreliant.think-freely.org>
 <52AE69A4.7090806@huawei.com>
 <20131216134814.GA19809@hmsreliant.think-freely.org>
 <52AF0ADF.7030704@gmail.com>
 <20131216143223.GB19809@hmsreliant.think-freely.org>
 <52AF130A.1090503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <weidong1991.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38154 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab3LPPEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:04:46 -0500
Content-Disposition: inline
In-Reply-To: <52AF130A.1090503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 10:49:46PM +0800, Wang Weidong wrote:
> From: Wang Weidong <wangweidong1@huawei.com>
> 
> On 2013/12/16 22:32, Neil Horman wrote:
> >On Mon, Dec 16, 2013 at 10:14:55PM +0800, Wang Weidong wrote:
> >>From: Wang Weidong <wangweidong1@huawei.com>
> >>
> >>On 2013/12/16 21:48, Neil Horman wrote:
> >>>On Mon, Dec 16, 2013 at 10:47:00AM +0800, Wang Weidong wrote:
> >>>>On 2013/12/13 20:26, Neil Horman wrote:
> >>>>>On Fri, Dec 13, 2013 at 11:00:10AM +0800, Wang Weidong wrote:
> >>>>>>when I modprobe sctp_probe, it failed with "FATAL: ". I found that
> >>>>>>sctp should load before sctp_probe register jprobe. So I add a
> >>>>>>sctp_setup_jprobe for loading 'sctp' when first failed to register
> >>>>>>jprobe, just do this similar to dccp_probe.
> >>>>>>
> >>>>>>v2: add MODULE_SOFTDEP and check of request_module, as suggested by Neil
> >>>>>>
> >>>>>>Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> >>>>>>---
> >>>>>>  net/sctp/probe.c | 17 ++++++++++++++++-
> >>>>>>  1 file changed, 16 insertions(+), 1 deletion(-)
> >>>>>>
> >>>>>>diff --git a/net/sctp/probe.c b/net/sctp/probe.c
> >>>>>>index 53c452e..5e68b94 100644
> >>>>>>--- a/net/sctp/probe.c
> >>>>>>+++ b/net/sctp/probe.c
> >>>>>>@@ -38,6 +38,7 @@
> >>>>>>  #include <net/sctp/sctp.h>
> >>>>>>  #include <net/sctp/sm.h>
> >>>>>>
> >>>>>>+MODULE_SOFTDEP("pre: sctp");
> >>>>>>  MODULE_AUTHOR("Wei Yongjun <yjwei@cn.fujitsu.com>");
> >>>>>>  MODULE_DESCRIPTION("SCTP snooper");
> >>>>>>  MODULE_LICENSE("GPL");
> >>>>>>@@ -182,6 +183,20 @@ static struct jprobe sctp_recv_probe = {
> >>>>>>  	.entry	= jsctp_sf_eat_sack,
> >>>>>>  };
> >>>>>>
> >>>>>>+static __init int sctp_setup_jprobe(void)
> >>>>>>+{
> >>>>>>+	int ret = register_jprobe(&sctp_recv_probe);
> >>>>>>+
> >>>>>>+	if (ret) {
> >>>>>>+		if (request_module("sctp"))
> >>>>>>+			goto out;
> >>>>>>+		ret = register_jprobe(&sctp_recv_probe);
> >>>>>>+	}
> >>>>>>+
> >>>>>>+out:
> >>>>>>+	return ret;
> >>>>>>+}
> >>>>>>+
> >>>>>>  static __init int sctpprobe_init(void)
> >>>>>>  {
> >>>>>>  	int ret = -ENOMEM;
> >>>>>>@@ -202,7 +217,7 @@ static __init int sctpprobe_init(void)
> >>>>>>  			 &sctpprobe_fops))
> >>>>>>  		goto free_kfifo;
> >>>>>>
> >>>>>>-	ret = register_jprobe(&sctp_recv_probe);
> >>>>>>+	ret = sctp_setup_jprobe();
> >>>>>You don't need to create your own function for this, you can collapse it down to
> >>>>>a call to try_then_request_module(regitser_jprobe(...), "sctp");
> >>>>>Neil
> >>>>>
> >>>>Hi Neil,
> >>>>
> >>>>I try to use try_then_request_module(!regitser_jprobe(...), "sctp"); I found that if
> >>>>I used this, I couldn't get the ture value which returned by register_jprobe(). Is the
> >>>>returned value not important? The problem("if sctp.ko doesn't exist") you had pointed out
> >>>>is exist as well.
> >>>>
> >>>>Regards.
> >>>>Wang
> >>>
> >>>Not sure I follow.  There appear to be lots of examples in the kernel where
> >>
> >>I do this just like the dccp/probe.c do. So I think it can be an example.
> >>
> >
> >Ah thats right, I remember doing this before now. My bad.
> >
> >>>exactly what you are trying to do is done.  try_then_request_module calls your
> >>>requested method, and if it returns non-zero, calls request_module, then calls
> >>
> >>No actually. Just look the definition:
> >>#define try_then_request_module(x, mod...) \
> >>          ((x) ?: (__request_module(true, mod), (x)))
> >>if x return non-zero, it will return the value, not call request_module.
> >>
> >>>your requested method again, returning the final result.  What problem are you
> >>>running into?
> >>>Neil
> >>>
> >>
> >>So I only can use it like this:
> >>try_then_request_module(!regitser_jprobe(...), "sctp");
> >>
> >>when register_jprobe return 0 indicates success, I get the value is 1. It is OK.
> >>
> >>when register_jprobe is non-zero indicates failed, then calls request_module,
> >>and last calls register_jprobe. Here,
> >>1)maybe it will failed return non-zero, what I get the value is !register_jprobe
> >>is 0 with losing the value.
> >>2)request_module failed with the sctp is not exist, it will do the register_jprobe
> >>as well.
> >>
> >>Is there I am wrong somewhere?
> >>
> >
> >It really seems like there should be a way to roll up what you want into the
> >try_then_request_module macro.  What about:
> >
> >ret = try_then_request_module((register_jprobe(...) == 0), "sctp");
> >
> The first problem maybe exist. because the last value is x. So if use this
> it always return (register_jprobe(...) == 0) while the value is only 1 or 0.
> 
> >That seems like it should work.  It will mask the actual return value of
> >register_jprobe though I think, which kind of sucks.  Its almost like we need
> >another variant of this macro that accepts an expected condition result so the
> >macro can use it to compare, something like:
> >
> >#define try_then_request_module_cond(x, result, mod...) \
> >	((x) == (result) ?: __request_module(true, mod), (x)))
> >
> >that would let you set an expected comparison value for your macro, but get the
> >result of the method if it still fails after the module is loaded, or if it
> >fails to load.
> 
> I think this is a good idea.
> 
> >
> >Thats probably a cleanup for a second patch.  I think your version two is
> >probably as close as we're going to get right now.  So for v2:
> >
> >Acked-by: Neil Horman <nhorman@tuxdriver.com>
> >
> Thanks.
> 
> Will you send the cleanup patch?
> 
Yeah, I'll look into developing a new macro and cleaning it up as soon as I can.

Thanks
Neil
