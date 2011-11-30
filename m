From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering support
 for passthru mode
Date: Wed, 30 Nov 2011 09:34:21 -0800
Message-ID: <4ED6691D.9070606@intel.com>
References: <20111109075449.13549.58135.stgit@rhel6.1>  <1321575301.2749.51.camel@bwh-desktop>  <4EC5A785.3060108@intel.com>  <1321577078.2749.58.camel@bwh-desktop>  <4EC68EBB.3080303@intel.com>  <1321638038.2883.28.camel@bwh-desktop>  <4ECA8D50.9080603@intel.com>  <1322584544.2684.20.camel@bwh-desktop> <1322587170.2684.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21189 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705Ab1K3Rea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 12:34:30 -0500
In-Reply-To: <1322587170.2684.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/29/2011 9:19 AM, Ben Hutchings wrote:
> On Tue, 2011-11-29 at 16:35 +0000, Ben Hutchings wrote:
>>
>> Maybe I missed something!
>>
>> Let's be clear on what our models are for filtering.  At the moment we
>> have MAC filters set through ndo_set_rx_mode and VF filters set through
>> ndo_set_vf_{mac,vlan}.
>>
>> Ignoring anti-spoofing for the moment, should the currently defined
>> filters look like this (a):
>>
>>                  TX ^   | RX
>>                     |   v
>> +------------------+---+-----------------+
>> |                  |  ++------------+    |
>> |                  |  |RX MAC filter|    |
>> |                  |  ++------------+    |
>> |                  |   |match            |
>> |                  ^   v                 |
>> |                  |  ++------------+    |
>> |                  |  |RX VF filters|    |
>> |                  |  +-------+-----+    |
>> |                 /|\     no /|\         |
>> |                | | \ match/ | |match 2 |
>> |                | ^  \    /  v |        |
>> |                | |   \  /match|        |
>> |                |  \   \/  1/  |        |
>> |                |   \  /\  /   |        |
>> |                ^    \/  \/    v        |
>> |                |    /\  /\    |        |
>> |                |   /  ||  \   |        |
>> |                |  /   ||   \  |        |
>> |                | /    ||    \ |        |
>> |                ||     ||     ||        |
>> +----------------++-----++-----++--------+
>>                   ||     ||     ||
>>                   PF    VF 1   VF 2
>>
>> or like this (b):
>>
>>                  TX ^   | RX
>>                     |   v
>> +------------------+---+-----------------+
>> |                  |  ++------------+    |
>> |                  |  |RX VF filters|    |
>> |                  |  ++--------+---+    |
>> |                  | no|match  /|        |
>> |                  ^   v      | |        |
>> |                  | +-+----+ | |        |
>> |                  | |RX MAC| | |        |
>> |                  | |filter| | |        |
>> |                  | +------+ | |        |
>> |                  |   |match | |        |
>> |                 /|\  |      | |        |
>> |                | | \ | match| |match 2 |
>> |                | ^  \/    1 v |        |
>> |                | |  /\      | |        |
>> |                |  \/  \    /  |        |
>> |                |  /\   \  /   |        |
>> |                ^ /  \   \/    v        |
>> |                ||    \  /\    |        |
>> |                ||     ||  \   |        |
>> |                ||     ||   \  |        |
>> |                ||     ||    \ |        |
>> |                ||     ||     ||        |
>> +----------------++-----++-----++--------+
>>                   ||     ||     ||
>>                   PF    VF 1   VF 2
>>
>> I think the current model is (a); do you agree?
>>
>> So is the proposed new model something like this (c):
>
> Corrected diagram:
>
>                  TX ^   | RX
>                     |   v
> +------------------+---+-----------------+
> |                  |  ++------------+    |
> |                  |  |RX MAC filter|    |
> |                  ^  ++------------+    |
> |                  |   |match            |
> |          no match|   v                 |
> |  +----------------+ ++------------+    |
> |  |loopback filters| |RX VF filters|    |
> |  +---------+-----++ +-------+-----+    |
> |           /|\   /|\ match  /|\         |
> |          v | `-+>+-+-.2   / | |        |
> |           \ \  | |m \ \   / | |        |
> |     match 0\ `-+-+.a \ \ /  v |        |
> |             \  | | \t \ X   / |        |
> |              \ |  \ \c X \ /  |        |
> |               \|   \ \h \ X   |        |
> |                \    \/\1 X \  v        |
> |                ||   /\ |/ \ \ |        |
> |                |v  /  ||   \ \|        |
> |                || /   ^|    \ |        |
> |                ||/    |v     ||        |
> |                ||     ||     ||        |
> +----------------++-----++-----++--------+
>                   ||     ||     ||
>                   PF    VF 1   VF 2
>
>> (I've labelled the new filters as loopback filters here, and I'm still
>> leaving out anti-spoofing.)
>>
>> If not, please explain what the new model *is*.

The new model is to incorporate a VEB into the NIC.  The current model 
doesn't address any of the requirements of a VEB in the NIC and this 
proposed set of patches allow us to set MAC filters for the *ports* on 
the internal NIC VEB.  Consider the PF and each of the VFs as just a 
port on the VEB.  We need the ability to set L2 filters (MAC, MC and 
VLAN) for each of the ports on that VEB.  There is no currently 
supported method for doing this.  So yes, this is a new model although 
it's a fairly simple one.

If you have an alternative proposal for allowing us to set L2 filters 
for the ports on our NIC VEB then I'm all ears (or eyes as the case may be).

- Greg
