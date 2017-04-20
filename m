From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: __sk_buff.data_end
Date: Wed, 19 Apr 2017 17:12:20 -0700
Message-ID: <20170420001218.GA38173@ast-mbp.thefacebook.com>
References: <1492637460.22185.6.camel@sipsolutions.net>
 <1492640459.22185.7.camel@sipsolutions.net>
 <58F7FA6D.5030000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34861 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968993AbdDTAM0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 20:12:26 -0400
Received: by mail-io0-f178.google.com with SMTP id r16so43075789ioi.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 17:12:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58F7FA6D.5030000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 02:01:49AM +0200, Daniel Borkmann wrote:
> On 04/20/2017 12:20 AM, Johannes Berg wrote:
> >On Wed, 2017-04-19 at 23:31 +0200, Johannes Berg wrote:
> >>Hi Alexei, Daniel,
> >>
> >>I'm looking at adding the __wifi_sk_buff I talked about, and I notice
> >>that it uses CB space to store data_end. Unfortunately, in a lot of
> >>cases, we don't have any CB space to spare in wifi.
> >
> >I guess I can work around this, would this seem reasonable?
> >
> >  struct bpf_skb_data_end {
> >         struct qdisc_skb_cb qdisc_cb;
> >-       void *data_end;
> >+       /*
> >+        * The alignment here is for mac80211, since that doesn't use
> >+        * a pointer but a u64 value and needs to save/restore that
> >+        * across running its BPF programs.
> >+        */
> >+       void *data_end __aligned(sizeof(u64));
> >  };
> 
> Yeah, should work as well for the 32 bit archs, on 64 bit we
> have this effectively already:
> 
> struct bpf_skb_data_end {
>         struct qdisc_skb_cb        qdisc_cb;             /*     0    28 */
> 
>         /* XXX 4 bytes hole, try to pack */
> 
>         void *                     data_end;             /*    32     8 */
> 
>         /* size: 40, cachelines: 1, members: 2 */
>         /* sum members: 36, holes: 1, sum holes: 4 */
>         /* last cacheline: 40 bytes */
> };
> 
> Can you elaborate on why this works for mac80211? It uses cb
> only up to that point from where you invoke the prog?

+1

also didn't we discuss that wifi has crazy non-linear skb?
this data/data_end is used by cls_bpf with headlen only
for direct packet access where performance matters.
Since wifi skbs have only eth in headlen, there is not much
pointing adding support for data/data_end to wifi.
Just use ld_abs/ld_ind instructions and load_bytes() helper.
