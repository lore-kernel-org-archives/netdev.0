From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 11 Feb 2016 13:16:52 +0100
Message-ID: <20160211131652.0b7066cb@griffin>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
	<20160211114124.17ae429a@griffin>
	<1455190731.4855.50.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbcBKMQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 07:16:56 -0500
In-Reply-To: <1455190731.4855.50.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Feb 2016 12:38:51 +0100, Paolo Abeni wrote:
> We are already sending by default zero UDP checksum when tunneling over
> vxlan/geneve light weight tunnel since the commit 35e2d1152b22
> ("tunnels: Allow IPv6 UDP checksums to be correctly controlled.").
> 
> Currently, geneve/vxlan lwt pairs tunneling over ipv6 are not able to
> talk each-other with default setting since the sender will set zero UDP
> checksum in the external header and the receiver will discard such
> packets.
> 
> This commit is intended to address the above issue.
> 
> Such issue could be addressed also by defaulting all lwt geneve/vxlan
> flows (comprising those tunneling over ipv4) to set the external UDP
> checksum, but a single lwt tunnel device can be used to terminate flows
> with different checksum settings.

Hmm, right. The checksumming in tx path is solely controlled by
TUNNEL_CSUM value in tun_flags and openvswitch does not set
OVS_TUNNEL_KEY_ATTR_CSUM by default.

This is another property that should have been per-interface and not
per-packet in metadata based mode :-/ But we cannot change it now.

We could probably provide a way for the ovs user space to control the
rx checksumming flag but as the tx flag can be set per-flow, it would
only lead to ovs allowing acceptance of zero rx checksums
unconditionally anyway.

I don't see a better way out of this now. Fortunately, this does not
affect route based tunneling.

Acked-by: Jiri Benc <jbenc@redhat.com>


We should follow up in ovs (user space) to set OVS_TUNNEL_KEY_ATTR_CSUM
by default, at least for IPv6.

 Jiri

-- 
Jiri Benc
