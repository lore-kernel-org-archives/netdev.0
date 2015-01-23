From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [E1000-devel] [PATCH 1/2] if_link: Add VF multicast promiscuous
 mode control
Date: Thu, 22 Jan 2015 23:18:23 -0800
Message-ID: <54C1F5BF.30105@gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>	<874mrlu18e.fsf@nemi.mork.no>	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07B7C@BPXM14GP.gisp.nec.co.jp>	<F6FB0E698C9B3143BDF729DF222866469129B7F5@ORSMSX110.amr.corp.intel.com>	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07F09@BPXM14GP.gisp.nec.co.jp>	<F6FB0E698C9B3143BDF729DF222866469129B844@ORSMSX110.amr.corp.intel.com>	<7F861DC0615E0C47A872E6F3C5FCDDBD05E08FF6@BPXM14GP.gisp.nec.co.jp>	<063D6719AE5E284EB5DD2968C1650D6D1CAD01D6@AcuExch.aculab.com>	<7F861DC0615E0C47A872E6F3C5FCDDBD05E090FE@BPXM14GP.gisp.nec.co.jp>	<F6FB0E698C9B3143BDF729DF222866469129BC03@ORSMSX110.amr.corp.intel.com>	<063D6719AE5E284EB5DD2968C1650D6D1CAD0C8A@AcuExch.aculab.com>	<F6FB0E698C9B3143BDF729DF222866469129BFFD@ORSMSX110.amr.corp.intel.com>	<87bnlqpq6v
 .fsf@nemi.mork.no>	<F6FB0E698C9B3143BDF729DF222866469129C09C@ORSMSX110.amr.corp.intel.com> <7F861DC0615E0C47A872E6F3C5FCDDBD05E0B6B1@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	=?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0B6B1@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/22/2015 04:32 PM, Hiroshi Shimamoto wrote:
>> Subject: RE: [E1000-devel] [PATCH 1/2] if_link: Add VF multicast pro=
miscuous mode control
>>> "Skidmore, Donald C" <donald.c.skidmore@intel.com> writes:
>>>
>>>> My hang up is more related to: without the nob to enable it (off b=
y
>>>> default) we are letting one VF dictate policy for all the other VF=
s
>>>> and the PF.  If one VF needs to be in promiscuous multicast so is
>>>> everyone else.  Their stacks now needs to deal with all the extra
>>>> multicast packets.  As you point out this might not be a direct
>>>> concern for isolation in that the VM could have 'chosen' to join a=
ny
>>>> Multicast group and seen this traffic.  My concern over isolation =
is
>>>> one VF has chosen that all the other VM now have to see this multi=
cast
>>>> traffic.
>>> Apologies if this question is stupid, but I just have to ask about =
stuff I don't
>>> understand...
>>>
>>> Looking at the proposed implementation, the promiscous multicast fl=
ag
>>> seems to be a per-VF flag:
>>>
>>> +int ixgbe_ndo_set_vf_mc_promisc(struct net_device *netdev, int vf,=
 bool
>>> +setting) {
>>> +	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
>>> +	struct ixgbe_hw *hw =3D &adapter->hw;
>>> +	u32 vmolr;
>>> +
>>> +	if (vf >=3D adapter->num_vfs)
>>> +		return -EINVAL;
>>> +
>>> +	adapter->vfinfo[vf].mc_promisc_enabled =3D setting;
>>> +
>>> +	vmolr =3D IXGBE_READ_REG(hw, IXGBE_VMOLR(vf));
>>> +	if (setting) {
>>> +		e_info(drv, "VF %u: enabling multicast promiscuous\n", vf);
>>> +		vmolr |=3D IXGBE_VMOLR_MPE;
>>> +	} else {
>>> +		e_info(drv, "VF %u: disabling multicast promiscuous\n", vf);
>>> +		vmolr &=3D ~IXGBE_VMOLR_MPE;
>>> +	}
>>> +
>>> +	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
>>> +
>>> +	return 0;
>>> +}
>>> +
>>>
>>> I haven't read the data sheet, but I took a quick look at the excel=
lent high
>>> level driver docs:
>>> http://www.intel.com/content/dam/doc/design-guide/82599-sr-iov-driv=
er-
>>> companion-guide.pdf
>>>
>>> It mentions "Multicast Promiscuous Enable" in its "Thoughts for
>>> Customization" section:
>>>
>>>  7.1 Multicast Promiscuous Enable
>>>
>>>  The controller has provisions to allow each VF to be put into Mult=
icast
>>> Promiscuous mode.  The Intel reference driver does not configure th=
is
>>> option .
>>>
>>>  The capability can be enabled/disabled by manipulating the MPE fie=
ld  (bit
>>> 28) of the PF VF L2 Control Register (PFVML2FLT =E2=80=93 0x0F000)
>>>
>>> and showing a section from the data sheet describing the "PF VM L2 =
Control
>>> Register - PFVML2FLT[n]  (0x0F000 + 4 * n, n=3D0...63; RW)"
>>>
>>> To me it looks like enabling Promiscuos Multicast for a VF won't af=
fect any
>>> other VF at all.  Is this really not the case?
>>>
>>>
>>>
>>> Bj=C3=B8rn
>> Clearly not a dumb question at all and I'm glad you mentioned that. =
:)  I was going off the assumption, been awhile since
>> I read the patch, that the patch was using FCTRL.MPE or MANC.MCST_PA=
SS_L2 which would turn multicast promiscuous on for
>> everyone.  Since the patch is using PFVML2FLT.MPE this lessens my co=
ncern over effect on the entire system.
> I believe the patches for this VF multicast promiscuous mode is per V=
=46.
>
>> That said I still would prefer having a way to override this behavio=
r on the PF, although I admit my argument is weaker.
>> I'm still concerned about a VF changing the behavior of the PF witho=
ut any way to prevent it.  This might be one part
>> philosophical (PF sets policy not the VF) but this still could have =
a noticeable effect on the overall system.  If any
>> other VFs (or the PF) are receiving MC packets these will have to be=
 replicated which will be a performance hit.  When
>> we use the MC hash this is limited vs. when anyone is in MC promiscu=
ous every MC packet used by another pool would be
>> replicated.  I could imagine in some environments (i.e. public cloud=
s) where you don't trust what is running in your VM
>> you might what to block this from happening.
> I understand your request and I'm thinking to submit the patches
>   1) Add new mbox API between ixgbe/ixgbevf to turn MC promiscuous on=
,
>      and enables it when ixgbevf needs over 30 MC addresses.
>   2) Add a policy knob to prevent enabling it from the PF.
>
> Does it seem okay?

I would advise that if such a knob is added it should be set to disable=
d
by default.  The main problem with supporting that many multicast
addresses per VF is that you run the risk for flooding the PCIe
interface on the network adapter if too many adapters were to go into
such a mode.

> BTW, I'm bit worried about to use ndo interface for 2) because adding=
 a
> new hook makes core code complicated.
> Is it really reasonable to do it with ndo?
> I haven't find any other suitable method to do it, right now. And usi=
ng
> ndo VF hook looks standard way to control VF functionality.
> Then, I think it's the best way to implement this policy in ndo hook.

The ndo is probably the only way to go on this.  It is how past control=
s
for the VF network functionality have been implemented.

>> In some ways it is almost the mirror image of the issue you brought =
up:
>>
>> Adding a new hook for this seems over-complicated to me.  And it sti=
ll
>> doesn't solve the real problems that
>>  a) the user has to know about this limit, and
>>  b) manually configure the feature
>>
>> My reverse argument might be that if this happens automatically.  It=
 might take the VM provider a long time to realize
>> performance has taken a hit because some VM asked to join 31 multica=
st groups and entered MC promiscuous.  Then only to
>> find that they have no way to block such behavior.
>>
>> Maybe I wouldn't as concerned if the patch author could provide some=
 performance results to show this won't have as a
>> negative effect as I'm afraid it might?
> Hm, what kind of test case would you like to have?
> The user A who has 30 MC addresses vs the user B who has 31 MC addres=
ses, which
> means that MC promiscuous mode, and coming MC packets the user doesn'=
t expect?
>
> thanks,
> Hiroshi

The question I would have is how many of these interfaces do you expect
to have supporting the expanded multicast mode?  As it currently stands
multicast traffic has the potential to flood the adapter, greatly reduc=
e
the overall throughput, and add extra workload to the PF and all VFs.=20
=46or example if several VFs enable this feature, and then someone on t=
he
network sends a stream of multicast traffic what happens to the CPU loa=
d
for the host system?

Also how many addresses beyond 30 is it you require?  An alternative to
adding multicast promiscuous might be to consider extending the mailbox
API to support sending more than 30 addresses via something such as a
multi-part multicast configuration message.  The fm10k driver already
has logic similar to this as it adds addresses 1 at a time though a
separate Switch interface API between the PF and the Switch.  You might
be able to reuse some of that code to reach beyond the 30 address limit=
=2E

- Alex
