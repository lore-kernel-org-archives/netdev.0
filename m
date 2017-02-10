From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to
 reflect HW offload status
Date: Fri, 10 Feb 2017 14:19:33 -0800
Message-ID: <20170210141933.6e51418e@cakuba.netronome.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
        <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35418 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750910AbdBJWTg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 17:19:36 -0500
Received: by mail-pg0-f41.google.com with SMTP id 194so13883647pgd.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 14:19:36 -0800 (PST)
In-Reply-To: <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Feb 2017 16:18:08 +0200, Or Gerlitz wrote:
> Currently there is no way of querying whether a filter is
> offloaded to HW or not when using both policy (no flag).
> 
> Reuse the skip flags to show the insertion status by setting
> the skip_hw flag in case the filter wasn't offloaded.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

FWIW I tested this one and it works.  I also tested this version which
would take advantage of @offloaded:

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d9c97018317d..51d464f991ff 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -568,8 +568,8 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			struct sk_buff *skb, struct tcmsg *tm)
 {
 	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) fh;
+	u32 gen_flags, bpf_flags = 0;
 	struct nlattr *nest;
-	u32 bpf_flags = 0;
 	int ret;
 
 	if (prog == NULL)
@@ -601,8 +601,11 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		bpf_flags |= TCA_BPF_FLAG_ACT_DIRECT;
 	if (bpf_flags && nla_put_u32(skb, TCA_BPF_FLAGS, bpf_flags))
 		goto nla_put_failure;
-	if (prog->gen_flags &&
-	    nla_put_u32(skb, TCA_BPF_FLAGS_GEN, prog->gen_flags))
+
+	gen_flags = prog->gen_flags;
+	if (!prog->offloaded)
+		gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
+	if (gen_flags && nla_put_u32(skb, TCA_BPF_FLAGS_GEN, gen_flags))
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
