From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch net-next v4 8/9] net: move vlan pop/push functions into
 common code
Date: Fri, 21 Nov 2014 20:29:33 +0100
Message-ID: <20141121202933.2970b7ea@griffin>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
	<1416402303-25341-9-git-send-email-jiri@resnulli.us>
	<CALnjE+pM=D=OEnkuC3h8iQHzF3Qc33CNA7CMgB2=H0hMboxiKQ@mail.gmail.com>
	<20141121180553.GA2251@nanopsycho.orion>
	<CALnjE+p3PtaOz7Ujp7KDK0-=giP-kzEDDDvw8=GCjJdcECYJEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <cwang@twopensource.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbaKUTaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 14:30:25 -0500
In-Reply-To: <CALnjE+p3PtaOz7Ujp7KDK0-=giP-kzEDDDvw8=GCjJdcECYJEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2014 10:41:27 -0800, Pravin Shelar wrote:
> There is bug in the openvswitch code where vlan-pop does mac-length
> reset rather than subtracting VLAN_HLEN  from mac-len. MPLS code
> depends on this. Now this patch moves the bug to common code. I am
> fine with this patch and I can send fix to change code vlan-pop code
> to adjust mac_len later on.
> But I am worried about the comment made by Jiri Benc on earlier
> version of this patch where is mentioned that subtracting VLAN_HLEN
> can break common case for vlan-pop. In that case we can not change
> this common function. Jiri Benc, Can you point me to the code, so the
> we can work on solution to fix this issue.

In such case, a skb that enters the __pop_vlan_tci function looks like
this:

+--------+--------+-------------+-----+---------+-------
| dstmac | srcmac | ETH_P_8021Q | tci | ETH_P_x | data
+--------+--------+-------------+-----+---------+-------
^                               ^
mac_header                      network_header

skb->protocol = ETH_P_8021Q
skb->mac_len = 14

After the function finishes, it's supposed to look like this:

                    +--------+--------+---------+-------
                    | dstmac | srcmac | ETH_P_x | data
                    +--------+--------+---------+-------
                    ^                           ^
                    mac_header                  network_header

skb->protocol = ETH_P_x
skb->mac_len = 14

Blindly decrementing mac_len wouldn't work here, you'd end up with
mac_len = 10. You'd either need to ensure this case doesn't happen (it
does with openvswitch currently) or detect this case.

 Jiri

-- 
Jiri Benc
