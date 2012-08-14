From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 14 Aug 2012 11:44:26 +0300
Message-ID: <502A0FEA.5050806@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <20120812102240.GG1421@redhat.com> <5027AC88.2020509@mellanox.com> <20120812135544.GB6003@redhat.com> <5027BA17.6010503@mellanox.com> <20120812205457.GA14081@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:43995 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754897Ab2HNIqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 04:46:07 -0400
In-Reply-To: <20120812205457.GA14081@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 23:54, Michael S. Tsirkin wrote:
> On Sun, Aug 12, 2012 at 05:13:43PM +0300, Or Gerlitz wrote:
>> On 12/08/2012 16:55, Michael S. Tsirkin wrote:
>>> I didn't realize you do ARP snooping. Why? I know you mangle
>>> outgoing ARP packets,
>>
>> Maybe I wasn't accurate/clear, we do mangle outgoing/incoming ARP
>> packets, from/to Ethernet ARPs to/from IPoIB ARPs.
>>
>>
>>> this will go away if you maintain a mapping in SM accessible to all guests.
>>
>> guests don't interact with IB, I assume you referred to dom0 code, eIPoIB or
>> another driver in the host. But what mapping exactly?
>
> Well we are getting into protocol design here.

wait... reading your responses again, I realized that we 1st and most 
have to (try and) agree on the
problem statement before going/jumping to solutions.

AFAIU your email/s you maybe think that we mandate the admin to set a 
specific MAC to the VM which is derived from the LID/QPN of the IPoIB 
VIF serving it, well this is wrong, we don't,  OTOH, indeed, the VM 
source mac isn't sent on the wire, since the Ethernet header is dropped, 
and on the receiving side is constructed from the LID/QPN
the IB packet arrived from, see next.

This reconstruction of what we call the REMAC (remote ethernet mac) is 
based in the current submission on
the LID/QPN, and as I said earlier on this thread, we are revisiting 
this approach -- where your idea below sounds
good: the eipoib driver can register with the SA an IB "service record" 
entry mapping from LID/QPN to the VM mac, when ever a VM is to be served 
by this eipoib instance, and remove the entry when the VM shouldn't be 
served any more. This will allow to preserve 1:1 the Ethernet MAC header 
sent by VMs on the receiving side.



> So here's a sketch showing how you could build a protocol that does work.  But note it is not *exactly* IPoIB.

HOWEVER, this doesn't touch the IPoIB wire protocol, and hence on the 
wire it IS exactly IPoIB. We only make use of your lovely suggestion to 
apply this SA assistance, so the change doesn't involve 
hardware/firmware nor the wire protocol.

Or.


> It is I think close enough that you can use existing NIC hardware/firmware, which is why it differs slightly from what Eric described, and is more complex.  But it still shares the same property of no hacks, no packet snooping in driver, etc.
>
>
> And if you want to go that route, you really should talk to some IB
> protocol people to figure out what works, write a spec and try to
> standardize. lkml/netdev is not the right place.
>
> But since you asked, if I had to, I would probably try to
> do it like this:
>
> - Each device registers with the SA specifying the
>    mac address (+ vlan?), SA stores the translation from that
>    to IPoIB address.
> - alternatively, SA admin configures the translation statically
> - you get a packet with 6 byte mac address,
>    query the SA for a mapping to IPoIB address, strip
>    ethernet frame and send
> - multicast GID addresses can be similar, filled either when registering
>    for multicast or by SA admin
>
> I think it's possible that you could also convert a mac address to
> EUI-64 and prepend a prefix to get a legal GID. But maybe I'm missing
> something.  This could be handy for multicast.
>
>
> In both cases:
> - SA could return GID that you then resolve to
>    LID using another query, or it could return LID so you save a roundtrip
> - results can be cached locally
> - SA can send updates when translation changes to flush this cache
>
>
> Now above means protocols such as ARP and DHCP use 48 bit addresses so
> you can not mix this new protocol with IPoIB.  Maybe IPoIB could simply
> ignore irrelevant packets, but it's best not to try, get a
> different all-broadcast group and CM ID instead to avoid confusion.
>
> One other interesting thing you can do is forward multicast
> registration data from the router, translate to mgid
> by the SA and do appropriate IB mcast registrations.
>
>
