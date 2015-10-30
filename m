From: Lan Tianyu <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV
 NIC
Date: Fri, 30 Oct 2015 10:41:12 +0800
Message-ID: <5632D8C8.3010101@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com> <562A7E33.4080800@gmail.com> <562DBBC9.4000104@intel.com> <562E40BB.6040404@gmail.com> <5631B8CA.9040805@intel.com> <5631C3A7.2070900@gmail.com> <5631D9C2.2040206@intel.com> <56324682.5060507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Duyck <alexander.duyck@gmail.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <56324682.5060507@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015=E5=B9=B410=E6=9C=8830=E6=97=A5 00:17, Alexander Duyck wrote:
> On 10/29/2015 01:33 AM, Lan Tianyu wrote:
>> On 2015=E5=B9=B410=E6=9C=8829=E6=97=A5 14:58, Alexander Duyck wrote:
>>> Your code was having to do a bunch of shuffling in order to get thi=
ngs
>>> set up so that you could bring the interface back up.  I would argu=
e
>>> that it may actually be faster at least on the bring-up to just dro=
p the
>>> old rings and start over since it greatly reduced the complexity an=
d the
>>> amount of device related data that has to be moved.
>> If give up the old ring after migration and keep DMA running before
>> stopping VCPU, it seems we don't need to track Tx/Rx descriptor ring=
 and
>> just make sure that all Rx buffers delivered to stack has been migra=
ted.
>>
>> 1) Dummy write Rx buffer before checking Rx descriptor to ensure pac=
ket
>> migrated first.
>=20
> Don't dummy write the Rx descriptor.  You should only really need to
> dummy write the Rx buffer and you would do so after checking the
> descriptor, not before.  Otherwise you risk corrupting the Rx buffer
> because it is possible for you to read the Rx buffer, DMA occurs, and
> then you write back the Rx buffer and now you have corrupted the memo=
ry.
>=20
>> 2) Make a copy of Rx descriptor and then use the copied data to chec=
k
>> buffer status. Not use the original descriptor because it won't be
>> migrated and migration may happen between two access of the Rx
>> descriptor.
>=20
> Do not just blindly copy the Rx descriptor ring.  That is a recipe fo=
r
> disaster.  The problem is DMA has to happen in a very specific order =
for
> things to function correctly.  The Rx buffer has to be written and th=
en
> the Rx descriptor.  The problem is you will end up getting a read-ahe=
ad
> on the Rx descriptor ring regardless of which order you dirty things =
in.


Sorry, I didn't say clearly.
I meant to copy one Rx descriptor when receive rx irq and handle Rx rin=
g.

Current code in the ixgbevf_clean_rx_irq() checks status of the Rx
descriptor whether its Rx buffer has been populated data and then read
the packet length from Rx descriptor to handle the Rx buffer.

My idea is to do the following three steps when receive Rx buffer in th=
e
ixgbevf_clean_rx_irq().

(1) dummy write the Rx buffer first,
(2) make a copy of its Rx descriptor
(3) Check the buffer status and get length from the copy.

Migration may happen every time.
Happen between (1) and (2). If the Rx buffer has been populated data, V=
=46
driver will not know that on the new machine because the Rx descriptor
isn't migrated. But it's still safe.

Happen between (2) and (3). The copy will be migrated to new machine
and Rx buffer is migrated firstly. If there is data in the Rx buffer,
VF driver still can handle the buffer without migrating Rx descriptor.

The next buffers will be ignored since we don't migrate Rx descriptor
for them. Their status will be not completed on the new machine.

--=20
Best regards
Tianyu Lan
