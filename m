From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Fri, 22 Apr 2016 23:27:32 +0200
Message-ID: <20160422232732.7dfd0ec3@griffin>
References: <cover.1461346798.git.jbenc@redhat.com>
	<017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
	<CAOrHB_DrFXg=nQAdscOgX8nbUoOC4fMsWiN6R4n907zB5rtD=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbcDVV1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 17:27:37 -0400
In-Reply-To: <CAOrHB_DrFXg=nQAdscOgX8nbUoOC4fMsWiN6R4n907zB5rtD=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Apr 2016 14:07:01 -0700, pravin shelar wrote:
> On Fri, Apr 22, 2016 at 10:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > For ipgre interfaces in collect metadata mode, receive also traffic with
> > encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
> > out correctly. This allows to have mixed Ethernet + L3-only traffic on the
> > same lwtunnel interface.
> >
> How user is suppose to sort out the type of packet? whether it is L2 or L3.

By skb->protocol, of course. Will be ETH_P_TEB if the inner packet was
Ethernet. There's no problem with this, for lwtunnels used with encap
routes, such packets are just discarded (which is the expected
behavior), as there's no protocol handler for ETH_P_TEB. More clever
lwtunnel users (such as openvswitch) can process the packets. This is
important in order to have a single tunnel interface for everything.

> Is it fine to receive L2 packet over L3 device?
> At least ip_tunnel_rcv() is not ready to handle such packet.

I don't see why. Could you please elaborate? Seems safe to me. The
desired result is skb->protocol == htons(ETH_P_TEB), network header(!)
pointing to the start of the Ethernet frame (because we're tunneling
Ethernet via ARPHRD_IPGRE interface, there's no L2 header to have), mac
header not being set.

 Jiri
