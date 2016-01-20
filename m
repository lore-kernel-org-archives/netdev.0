From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: ethtool NFC/ntuple API questions
Date: Wed, 20 Jan 2016 09:53:11 -0800
Message-ID: <CAKgT0Ud1OprxqjYQC4NrFmRyhrG4x1G2=dWZEKwW866XAyW-eA@mail.gmail.com>
References: <569FBF9D.40002@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34024 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836AbcATRxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 12:53:12 -0500
Received: by mail-ig0-f179.google.com with SMTP id ik10so105992661igb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 09:53:11 -0800 (PST)
In-Reply-To: <569FBF9D.40002@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 9:10 AM, Edward Cree <ecree@solarflare.com> wrote:
> I'm looking into adding IPv6 support to the ethtool flow steering API.  But,
> I don't know "the unfortunate history of and subtle differences between the
> RX n-tuple versus RX NFC commands".  In particular, would I need to add IPv6
> support to both of them, or only one?  If one would be sufficient, which one
> is preferred?

I'd say just focus on Rx NFC.  The NTUPLE interface is only really
used for legacy support on ixgbe if I recall correctly.  The original
implementation was badly broken, but because it went out we are stuck
supporting it.  Any new features can be added to the Rx NFC since that
is the interface that has the ability to both set and get filters.

> Also, is it necessary to duplicate the profusion of variants that the IPv4
> flow specs have (3x struct ethtool_tcpip4_spec, 2x struct
> ethtool_ah_espip4_spec, and struct ethtool_usrip4_spec), or should I just
> make one struct that contains all the fields from those (I would say "the
> union of their fields", but that might be confusing), and rely on flow_type
> to indicate which fields are meaningful?

I'd say just stick with the approach taken for IPv4 since it makes it
much more readable.  There were only really 4 types in use, but we
named each to make certain it was clear which one should be used for
each type.  To some extent the approach of relying on the flow_type is
already in use, it is just made clearer by specifying which union to
use for each type.

> And, what exactly are the hdata fields in ethtool_flow_union and the
> anonymous union in ethtool_rx_ntuple_flow_spec (they're not documented) and
> why are they different sizes?

The hdata is essentially just padding that defines the entire region
size.  For the user interface we have to reserve some amount of space,
and in order to make the flow definitions compatible with NTUPLE we
added extensions so that we could provide the information about the
VLAN header if needed.

The reason for the sizing difference is that the ethtool_flow_union is
half of the flow definition, the other half is stored in
ethtool_flow_ext.  We shimmed ethtool_flow_ext into Rx NFC in order to
work around the limitations of the NTUPLE filters.  The structure you
probably should be looking at for comparison to NTUPLE is
ethtool_rx_flow_spec, not ethtool_flow_union as that helps to tell the
whole story.

- Alex
