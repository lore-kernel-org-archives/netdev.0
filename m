From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v6] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 13 Oct 2016 18:58:37 +0300
Message-ID: <20161013155837.GD1847@uranus.lan>
References: <20161006100055.GA1941@uranus.lan>
 <20161012.015022.2273537782016406180.davem@davemloft.net>
 <20161012065329.GH1941@uranus.lan>
 <20161012.195504.658773172040030000.davem@davemloft.net>
 <20161013071648.GA1946@uranus.lan>
 <e59c339f-ca3d-92e9-88e0-8c3e9e02e01a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, jhs@mojatatu.com,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34302 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754969AbcJMQLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:11:16 -0400
Content-Disposition: inline
In-Reply-To: <e59c339f-ca3d-92e9-88e0-8c3e9e02e01a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2016 at 09:43:57AM -0600, David Ahern wrote:
> On 10/13/16 1:16 AM, Cyrill Gorcunov wrote:
> > On Wed, Oct 12, 2016 at 07:55:04PM -0400, David Miller wrote:
> >> From: Cyrill Gorcunov <gorcunov@gmail.com>
> >> Date: Wed, 12 Oct 2016 09:53:29 +0300
> >>
> >>> I can't rename the field, neither a can use union.
> >>
> >> Remind me again what is wrong with using an anonymous union?
> > 
> > Anon union would be a preferred but Eric pointed me that even
> > though it might cause problems (https://patchwork.kernel.org/patch/9353365/)
> > 
> >  | Note that some programs could fail to compile with the added union
> >  | anyway.
> >  |
> >  | Some gcc versions are unable to compile a static init with an union
> >  |
> >  | struct inet_diag_req_v2 foo = { .pad = 0, sdiag_family = AF_INET, };
> >  |
> >  | When I cooked my recent fq commit I simply removed a pad and replaced
> >  | it :
> >  |
> >  | git show fefa569a9d4bc4 -- include
> > 
> 
> That commit suggests it is acceptable to just rename the
> pad field, which is the simplest approach.

No. In further message Eric points that

| This is a bit different of course, since struct tc_fq_qd_stats is only
| one way : Kernel produces the content and gives it to user space.

and we are simply lucky that we didn't break anything in userspace yet.
IOW, it's not a problem for me simply to

 - rename it or,
 - use anonymous union

but both options have own problems :/

Also I just thought what if we introduce

struct inet_diag_req_raw_v2 {
	__u8	sdiag_family;
	__u8	sdiag_protocol;
	__u8	idiag_ext;
	__u8	sdiag_raw_protocol;
	__u32	idiag_states;
	struct inet_diag_sockid id;
};

where @sdiag_raw_protocol explicitly stated and
will collide with existing struct inet_diag_req_v2?
This is a hack too of course but at least this
won't break api definitely.
