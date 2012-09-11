From: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Subject: Re: [RFC PATCH 0/5] Reorganize libfcoe control interfaces
Date: Tue, 11 Sep 2012 11:31:08 -0700
Message-ID: <504F836C.3040907@broadcom.com>
References: <20120910225908.13140.97277.stgit@fritz>
 <CAHNqLyUUeVPVzvZCKzmbp0LdOGnOYudOehVfagySokrq8zj4hA@mail.gmail.com>
 <504F76A1.50809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Chris Leech" <leech@pobox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>
To: "Love, Robert W" <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <504F76A1.50809@intel.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/11/2012 10:36 AM, Love, Robert W wrote:
> On Tue 11 Sep 2012 10:06:29 AM PDT, Chris Leech wrote:
>> On Mon, Sep 10, 2012 at 3:59 PM, Robert Love <robert.w.love@intel.co=
m> wrote:
>
> <snip>
>
>>> 1) Create/alloc the port
>>>      - Allocate kernel memory and create per-instance sysfs devices
>>>      - No discovery or login
>>>
>
> # echo eth3.172-fcoe > /sys/bus/fcoe/ctlr_create

I'm assuming the existing functionality of automatically creating the=20
vlan interface by fcoemon (using the cfg-ethX) continues to exist and=20
the above is not a replacement for fcoeadm -c.

>
> results in:
>
> /sys/bus/fcoe/devices/ctlr_0/
>
>>> 2) Configure the port
>>>      - Change mode, set ddp_min, etc...
>>>
>
> # echo "Fabric" > /sys/bus/fcoe/devices/ctlr_0/mode
>
> no visible change
>
>>> 3) Start the port
>>>      - Begins discovery and/or login (depending on mode)
>>>
>
> # echo 1 > /sys/bus/fcoe/devices/ctlr_0/start
>
> Begins discovery and login. Assuming there are FCFs then results in:
>
> /sys/bus/fcoe/devices/fcf_0

I'm also assuming that the above three steps can be clubbed by=20
fcoeutils, perhaps by adding 'mode' parameter into the cfg-ethX file.=20
That way 'service fcoe start' will be no different with the proposed=20
model, except that there will be multiple entry points into the driver=20
(alloc, config, start) instead of just one (create).

>
>>> 4) Destroy the port
>>>      - Logout and free all memory
>
> # echo eth3.172-fcoe > /sys/bus/fcoe/ctlr_destroy
>
> /sys/bus/fcoe/devices/ctlr_0 is removed.
>
>>>
>>> I'm looking for feedback on using sysfs files as control interfaces=
 that
>>> the user (application) would write interface names to. I modeled th=
is
>>> series off of the bonding sysfs interface, but it was suggested to =
me that
>>> it might not be a good example. I belive bonding uses two values pe=
r-file
>>> a '+' or a '-" to add or delete and then the ifname apended. I am s=
imply
>>> writing the ifname to the ctlr_create or ctlr_destroy.
>>
>> Can you give an example session that goes through the 4 steps above
>> and what the sysfs hierarchy looks like at each step?  I mostly get =
it
>> from the patch descriptions, but I think it would help discussion of
>> your proposed interfaces to see an example of them in use.
>>
>
> See above. bash-style.
>
>> This feels a little awkward with all the special control files.  Hav=
e
>> you thought about something designed for creating kernel objects, li=
ke
>> configfs?  Similarly the separate start, enable, disable files vs.
>
> Let me do some more reading about configfs. I may not have given it
> enough thought.
>
>> having some sort of status attribute that can take different values.
>> I feel like these need to be rethought as attributes instead of
>> triggers.  Is there a big difference between start and enable?  Can
>> you achieve the split between create and start by having it come up =
in
>> a disabled state by default?
>>
>
> It's a good idea. I'll look into it.
>
>> That being said, I'm glad this is being reworked.  Do you have any
>> other functionality in mind that this is laying the groundwork for?
>>
>
> I have one feature and a few ideas. I currently have a patch that add=
s
> a fabric selection feature. I add another RW attribute to the ctlr_X
> device. If the user writes fabric name to the file libfcoe uses it in
> it's FCF selection algorithm. Here's my commit message from that patc=
h.
> I can share the patch if people would like to see it too. The current
> implementation also allows the user to force the login through a
> specific FCF.
>
>       libfcoe, bnx2fc, fcoe: Add 'selection' attribute
>
>      This patch adds a 'selection' attribute to the
>      fcoe_ctlr_device. The user can write either a
>      '0x' prefixed fabric name or a ':' separated
>      MAC address to this file. If a fabric name is
>      provided the fcoe ctlr will only consider FCFs
>      with the fabric name when choosing a FCF to login
>      to. If a MAC address is provided the initiator
>      will only login to a FCF with the given Ethernet
>      address. Only one selection is valid at a time.
>
>      There are corresponding changes to fcoe-utils
>      to take advantage of this kernel feature and
>      to make it more accessible for the user.
>
> To accompany this feature I created a new fipfcf application based on
> fipvlan that sends out a discovery solicitation and displays
> advertising FCFs.
>
> I've also been talking with Mark Rustad about doing an 'auto' mode
> where Fabric discovery is attempted first and if it fails then it tri=
es
> VN2VN discovery, but so for we've only had hallway conversations abou=
t
> it and nothing has been flushed out.
>
> Thanks, //Rob=04=EF=BF=BD{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD+%=EF=BF=BD=EF=BF=BDlzwm=EF=BF=BD=EF=BF=BD=
b=EF=BF=BD=EB=A7=B2=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDzX=EF=BF=BD=EF=BF=
=BD=1B=1C=EF=BF=BD(=EF=BF=BD=EF=BF=BD=17=EF=BF=BD=EF=BF=BD=DC=A8}=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=C6=A0z=EF=BF=BD&j:+v=EF=BF=BD=EF=BF=BD=EF=BF=BD=07=
=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDzZ+=EF=BF=BD=EF=BF=BD+zf=EF=BF=BD=EF=
=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD~=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BDi=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD=1E=EF=BF=BDw=EF=BF=BD=EF=
=BF=BD=EF=BF=BD?=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD)=DF=A2=1B=
f
>


--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
