From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sched: cls_bpf: add BPF-based classifier
Date: Mon, 28 Oct 2013 08:27:14 -0700
Message-ID: <1382974034.4344.5.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382960120-2198-1-git-send-email-dborkman@redhat.com>
	 <1382967292.13037.22.camel@edumazet-glaptop.roam.corp.google.com>
	 <526E7556.1060902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:33200 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab3J1P1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 11:27:17 -0400
Received: by mail-pb0-f47.google.com with SMTP id rq2so6544172pbb.6
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 08:27:17 -0700 (PDT)
In-Reply-To: <526E7556.1060902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-28 at 15:31 +0100, Daniel Borkmann wrote:

> I thought about this, I think this can partially be resolved by the
> user implementing one BPF program to match all possible flows for a
> class instead of implementing multiple BPF programs as mentioned in
> the commit, iow that's up to the user space. And the case you suggest,
> would be another option to further improve this, but would come with
> some difficulties in contrast to the notion 0: mismatch, !0: match.
> I think, this would need additional walk-through through all 'ret'
> opcodes to see if those classes actually exist. Then, we would need
> refcounting and call tcf_{un,}bind_filter() for each class that is
> related to this filter, and tcf_exts_exec() would either need to be
> i) understood in a "per-filter" notion, so as long as something
> matches (!0) exec the very same action/policy (which might not be
> what we want) or ii) could just not be implemented as multiple
> user-defined filters could be defined in iproute2 with different
> actions each, but in some paths return the same flowid. So I think
> this here seems the better trade-off.

I have no idea why you want to do all this.

classid are not checked at filter installation time, but at run time.

All you need to do is change :

+       list_for_each_entry(prog, &head->plist, link) {
+               if (SK_RUN_FILTER(prog->filter, skb) == 0)
+                       continue;
+
+               *res = prog->res;
+               ret = tcf_exts_exec(skb, &prog->exts, res);
+               if (ret < 0)
+                       continue;
+
+               return ret;
+       }

to

	list_for_each_entry(prog, &head->plist, link) {
		int filter_res = SK_RUN_FILTER(prog->filter, skb);

		if (!filter_res)
			continue;


               *res = prog->res;
		if (filter_res != -1)
			res->classid = filter_res;

               ret = tcf_exts_exec(skb, &prog->exts, res);
               if (ret < 0)
                       continue;

               return ret;
       }

(Reserving filter returns codes :
 0 : No match
 -1: select classid given in the "tc filter ...." command)
other values : flowid, overiding the default one.
