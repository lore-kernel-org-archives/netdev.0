From: Jesse Gross <jesse@nicira.com>
Subject: Re: TX offloads for NVGRE (OVS GRE with inner protocol being TEB)
Date: Thu, 19 Feb 2015 09:01:16 -0800
Message-ID: <CAEP_g=_SSKYEhmQ2MXJN0wP8POiwjg49txExdrorUkzw8oCRmg@mail.gmail.com>
References: <54E5ED9D.8080206@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:33282 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753130AbbBSRBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 12:01:55 -0500
Received: by mail-lb0-f171.google.com with SMTP id b6so988193lbj.12
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 09:01:38 -0800 (PST)
In-Reply-To: <54E5ED9D.8080206@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 6:05 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Hi,
>
> It seems that the OVS GRE code lacks handling of offloads (e.g to come into
> play with NICs that support NVGRE).
>
> I assume we need to place a call to iptunnel_handle_offloads before invoking
> iptunnel_xmit, agree? so ~the quick patch below should do the work? I wasn't
> sure how to set the value of the 2nd param for iptunnel_handle_offloads().

I don't think that this is the issue. __build_header() calls
gre_handle_offloads() which should do all of this work already.

I did notice that skb_set_inner_protocol() is not being called because
it is in the wrong place in the GRE encapsulation code. It is
currently in ip_gre.c():__gre_xmit(), if that line was moved to
gre_demux.c:gre_build_header() then it would be used by all callers.

One other thing that is potentially an issue for offloads is that all
of the encapsulations call vlan_hwaccel_push_inside() after the
respective handle_offloads code. This doesn't seem right as it could
affect the layer pointers, although it only likely matters in a
minority of cases where the inner MAC pointer is used.
