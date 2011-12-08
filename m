From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 0/5] Series short description
Date: Thu, 08 Dec 2011 18:06:53 +0800
Message-ID: <4EE08C3D.5080306@redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<87ty5cj0sw.fsf@rustcorp.com.au> <4EDF4E82.7050201@redhat.com>
	<1323277324.2728.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1323277324.2728.34.camel@bwh-desktop>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 12/08/2011 01:02 AM, Ben Hutchings wrote:
> On Wed, 2011-12-07 at 19:31 +0800, Jason Wang wrote:
>> On 12/07/2011 03:30 PM, Rusty Russell wrote:
>>> On Mon, 05 Dec 2011 16:58:37 +0800, Jason Wang<jasowang@redhat.com>   wrote:
>>>> multiple queue virtio-net: flow steering through host/guest cooperation
>>>>
>>>> Hello all:
>>>>
>>>> This is a rough series adds the guest/host cooperation of flow
>>>> steering support based on Krish Kumar's multiple queue virtio-net
>>>> driver patch 3/3 (http://lwn.net/Articles/467283/).
>>> Is there a real (physical) device which does this kind of thing?  How do
>>> they do it?  Can we copy them?
>>>
>>> Cheers,
>>> Rusty.
>> As far as I see, ixgbe and sfc have similar but much more sophisticated
>> mechanism.
>>
>> The idea was originally suggested by Ben and it was just borrowed form
>> those real physical nic cards who can dispatch packets based on their
>> hash. All of theses cards can filter the flow based on the hash of
>> L2/L3/L4 header and the stack would tell the card which queue should
>> this flow goes.
> Solarflare controllers (sfc driver) have 8192 perfect filters for
> TCP/IPv4 and UDP/IPv4 which can be used for flow steering.  (The filters
> are organised as a hash table, but matched based on 5-tuples.)  I
> implemented the 'accelerated RFS' interface in this driver.
>
> I believe the Intel 82599 controllers (ixgbe driver) have both
> hash-based and perfect filter modes and the driver can be configured to
> use one or the other.  The driver has its own independent mechanism for
> steering RX and TX flows which predates RFS; I don't know whether it
> uses hash-based or perfect filters.

As far as I see, their driver predates RFS by binding the TX queue and 
RX queue to the same CPU and adding hash based filter during packet 
transmission.

> Most multi-queue controllers could support a kind of hash-based
> filtering for TCP/IP by adjusting the RSS indirection table.  However,
> this table is usually quite small (64-256 entries).  This means that
> hash collisions will be quite common and this can result in reordering.
> The same applies to the small table Jason has proposed for virtio-net.
>

Thanks for the clarification. Consider the hash were provided by host 
nic or host kernel, the collision rate is not fixed. Perfect filter is 
more suitable then.
>> So in host, a simple hash to queue table were introduced in tap/macvtap
>> and in guest, the guest driver would tell the desired queue of a flow
>> through changing this table.
> I don't think accelerated RFS can work well without the use of perfect
> filtering or hash-based filtering with a very low rate of collisions.
>
> Ben.
>
