From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [patch net-next v4 8/9] net: move vlan pop/push functions into
 common code
Date: Wed, 3 Dec 2014 16:33:57 -0800
Message-ID: <CALnjE+r0U9-cTZYZh=qzWoztfV_TNFoB762CBcDjUj1Z5oDYag@mail.gmail.com>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
	<1416402303-25341-9-git-send-email-jiri@resnulli.us>
	<CALnjE+pM=D=OEnkuC3h8iQHzF3Qc33CNA7CMgB2=H0hMboxiKQ@mail.gmail.com>
	<20141121180553.GA2251@nanopsycho.orion>
	<CALnjE+p3PtaOz7Ujp7KDK0-=giP-kzEDDDvw8=GCjJdcECYJEA@mail.gmail.com>
	<20141121202933.2970b7ea@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <cwang@twopensource.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:57728 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752309AbaLDAd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 19:33:58 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so13785530igi.12
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 16:33:57 -0800 (PST)
In-Reply-To: <20141121202933.2970b7ea@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2014 at 11:29 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 21 Nov 2014 10:41:27 -0800, Pravin Shelar wrote:
>> There is bug in the openvswitch code where vlan-pop does mac-length
>> reset rather than subtracting VLAN_HLEN  from mac-len. MPLS code
>> depends on this. Now this patch moves the bug to common code. I am
>> fine with this patch and I can send fix to change code vlan-pop code
>> to adjust mac_len later on.
>> But I am worried about the comment made by Jiri Benc on earlier
>> version of this patch where is mentioned that subtracting VLAN_HLEN
>> can break common case for vlan-pop. In that case we can not change
>> this common function. Jiri Benc, Can you point me to the code, so the
>> we can work on solution to fix this issue.
>
> In such case, a skb that enters the __pop_vlan_tci function looks like
> this:
>
> +--------+--------+-------------+-----+---------+-------
> | dstmac | srcmac | ETH_P_8021Q | tci | ETH_P_x | data
> +--------+--------+-------------+-----+---------+-------
> ^                               ^
> mac_header                      network_header
>
> skb->protocol = ETH_P_8021Q
> skb->mac_len = 14
>
> After the function finishes, it's supposed to look like this:
>
>                     +--------+--------+---------+-------
>                     | dstmac | srcmac | ETH_P_x | data
>                     +--------+--------+---------+-------
>                     ^                           ^
>                     mac_header                  network_header
>
> skb->protocol = ETH_P_x
> skb->mac_len = 14
>
> Blindly decrementing mac_len wouldn't work here, you'd end up with
> mac_len = 10. You'd either need to ensure this case doesn't happen (it
> does with openvswitch currently) or detect this case.
>

OVS correctly sets mac header length in case of vlan header. Can you
give me OVS test case to reproduce this issue?
