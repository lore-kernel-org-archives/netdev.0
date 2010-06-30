From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCHv2] vhost-net: add dhclient work-around from userspace
Date: Wed, 30 Jun 2010 18:24:37 -0500
Message-ID: <4C2BD235.5080506@codemonkey.ws>
References: <20100628100807.GA30685@redhat.com>
	<20100629.003647.214219303.davem@davemloft.net>
	<20100629130439.GD3603@redhat.com> <4C2BC04B.3000100@codemonkey.ws>
	<20100630223157.GA25537@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, kvm@vger.kernel.org, quintela@redhat.com,
        herbert.xu@redhat.com, linux-kernel@vger.kernel.org,
        virtualization@lists.osdl.org, ykaul@redhat.com, arozansk@redhat.com,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20100630223157.GA25537@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 06/30/2010 05:31 PM, Michael S. Tsirkin wrote:
> On Wed, Jun 30, 2010 at 05:08:11PM -0500, Anthony Liguori wrote:
>    
>> On 06/29/2010 08:04 AM, Michael S. Tsirkin wrote:
>>      
>>> On Tue, Jun 29, 2010 at 12:36:47AM -0700, David Miller wrote:
>>>        
>>>> From: "Michael S. Tsirkin"<mst@redhat.com>
>>>> Date: Mon, 28 Jun 2010 13:08:07 +0300
>>>>
>>>>          
>>>>> Userspace virtio server has the following hack
>>>>> so guests rely on it, and we have to replicate it, too:
>>>>>
>>>>> Use port number to detect incoming IPv4 DHCP response packets,
>>>>> and fill in the checksum for these.
>>>>>
>>>>> The issue we are solving is that on linux guests, some apps
>>>>> that use recvmsg with AF_PACKET sockets, don't know how to
>>>>> handle CHECKSUM_PARTIAL;
>>>>> The interface to return the relevant information was added
>>>>> in 8dc4194474159660d7f37c495e3fc3f10d0db8cc,
>>>>> and older userspace does not use it.
>>>>> One important user of recvmsg with AF_PACKET is dhclient,
>>>>> so we add a work-around just for DHCP.
>>>>>
>>>>> Don't bother applying the hack to IPv6 as userspace virtio does not
>>>>> have a work-around for that - let's hope guests will do the right
>>>>> thing wrt IPv6.
>>>>>
>>>>> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
>>>>>            
>>>> Yikes, this is awful too.
>>>>
>>>> Nothing in the kernel should be mucking around with procotol packets
>>>> like this by default.  In particular, what the heck does port 67 mean?
>>>> Locally I can use it for whatever I want for my own purposes, I don't
>>>> have to follow the conventions for service ports as specified by the
>>>> IETF.
>>>>
>>>> But I can't have the packet checksum state be left alone for port 67
>>>> traffic on a box using virtio because you have this hack there.
>>>>
>>>> And yes it's broken on machines using the qemu thing, but at least the
>>>> hack there is restricted to userspace.
>>>>          
>>> Yes, and I think it was a mistake to add the hack there. This is what
>>> prevented applications from using the new interface in the 3 years
>>> since it was first introduced.
>>>        
>> It's far more complicated than that.  dhclient is part of ISC's DHCP
>> package.  They do not have a public SCM and instead require you to
>> join their Software Guild to get access to it.
>>
>> This problem was identified in one distribution and the patch was
>> pushed upstream but because they did not have a public SCM, most
>> other distributions did not see the fix until it appeared in a
>> release.  ISC has a pretty long release cycle historically.
>>
>> ISC's had the fix for a long time but there was a 3-year gap in
>> their releases and since their SCM isn't public, users are stuck
>> with the last release.
>>
>> This hack makes sense in QEMU as we have a few hacks like this to
>> fix broken guests.
>>   A primary use of virtualization is to run old
>> applications so it makes sense for us to do that.
>>      
> IMO it was wrong to put it in qemu: originally, if a distro shipped
> a broken virtio/dhclient combo, it was it's own bug to fix.
> But now that qemu has shipped the work-around for so long,
> broken guests seemed work.

The guests were broken before qemu implemented this.

virtio-net had checksum offload long before it was ever implemented in 
qemu.  Not even lguest implemented it because the interfaces weren't 
available in tun/tap.  I'm not sure how Rusty ever tested it.  We only 
discovered this bug after checksum offload was implemented in tun/tap 
and we were able to enable it in QEMU.  At that point, the guests had 
shipped and were in the wild.

The real problem was that we implemented a feature in a guest driver 
without having a backend implementation and then shipped the code.  
Shipping untested code is a recipe for failure.

If we had implemented the front-end feature only when a backend 
implementation was available, we would have caught this, fixed it in the 
guests, and not be in the situation because there wouldn't be these 
broken guests.


>   So we *still* see the bug re-surface in new guests.
>    

Which guests?  Newer versions of dhclient should work as expected.

> And since they are fairly new, it is interesting to
> get decent performance from them now.
>
>    
>> I don't think it makes sense for vhost to do this.  These guests are
>> so old that they don't have the requisite features to achieve really
>> high performance anyway.
>>
>> I've always thought making vhost totally transparent was a bad idea
>> and this is one of the reasons.
>>      
> It does not have to be fully transparent. You can insert your own ring
> in the middle, and copy descriptors around.  And we stop on errors and
> let userspace handle.  This will come handy if we get e.g. virtio bug
> that we need to work around.
>    

I mean from a UI perspective.  IOW, if users have to explicitly choose 
to use vhost-net, then it's okay to force them to use newer guests that 
support vhost-net.  However, if we make it transparent, then it has to 
support everything that QEMU virtio has ever supported which is 
problematic for exactly the reasons you are now encountering.

>> We can do a lot of ugly things in
>> userspace that we shouldn't be doing in the kernel.
>>
>> Regards,
>>
>> Anthony Liguori
>>      
> QEMU is only userspace for the host. It is the hardware for the guest.
> So IMO we should not be doing the ugly things there either.
>    

Shouldn't we apply the same argument to the Windows RTC implementation 
and say that Windows should not rely on counting interrupts?  Or that it 
shouldn't spin in a tight loop checking interrupt status with interrupts 
disabled after receiving an interrupt?

Supporting broken guests is a big part of what we do in QEMU.  We do 
what we need to do to make guests that we cannot change work.  When this 
first was implemented, there were a good number of pre-existing guests 
that broke because we enabled checksum offload.

If we can fix the guests to avoid doing ugly things in QEMU, we should, 
but we can't regress an otherwise working guest just because we think 
the solution is ugly in QEMU.

Regards,

Anthony Liguori
