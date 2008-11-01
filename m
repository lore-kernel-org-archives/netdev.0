From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: e1000 kills IPMI on 82541GI (Dell PE1425SC) +
 small 2.6.27 regression
Date: Sat, 1 Nov 2008 05:20:19 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0811010410110.12764@bizon.gios.gov.pl>
References: <alpine.LNX.1.10.0810311012160.12764@bizon.gios.gov.pl>
	<F169D4F5E1F1974DBFAFABF47F60C10A0D2A5710@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="-1144830174-1544616819-1225513221=:12764"
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A0D2A5710@orsmsx507.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1544616819-1225513221=:12764
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by bizon.gios.gov.pl id
	mA14KLw2023012



On Fri, 31 Oct 2008, Brandeburg, Jesse wrote:

> <modified the mail list a bit>
>
> Krzysztof Oledzki wrote:
>> I have started implementing IPMI on my servers and there is some
>> inconvenience with e1000+82541GI (Dell PE1425SC).
>
> ugh, sorry to hear about that.
>
>> With older kernels IPMI works if there are no vlans attached to
>> primary interface. Adding vlans breaks it as e1000 driver enables
>> VLAN filter and it somehow interferences with IPMI.
>>
>> (no vlans):
>> # ethtool -d eth0|grep -i vlan
>>        VLAN mode:                         disabled
>>        VLAN filter:                       disabled
>>
>> (vlans):
>> # ethtool -d eth0|grep -i vlan
>>        VLAN mode:                         enabled
>>        VLAN filter:                       enabled
>
> vlan enable does a couple of things, it mostly just allows the device t=
o
>
> strip the vlan tag (that matches our vlan table in hardware) from
> incoming
> packets and put it in the rx descriptor. This modifies the original
> packet as the vlan is stripped.

So, the same vlan table is used for both host OS and IPMI, right?

>> However, I found that using a workaround by adding the IPMI vlan to
>> the OS restores the functionality. Very ugly but works.
>
> interesting, this is whith the older <=3D 2.6.26 kernel right?

Yep, exactly. So far I have tested 2.6.22, 2.6.24, 2.6.26 and 2.6.27=20
kernels.

If there are no vlans configured on a host I have:

<=3D2.6.26:
# ethtool -d eth0|grep -i vlan
       VLAN mode:                         disabled
       VLAN filter:                       disabled

>=3D2.6.27:
# ethtool -d eth0|grep -i vlan
       VLAN mode:                         disabled
       VLAN filter:                       enabled


>> So, it is OK with no-vlan-enabled hosts and with vlan-enabled with the
>> above workaround, but still - it is a ugly workaround: IPMI is
>> non-functional until OS *properly* initializes network configuration,
>> which may never happen.
>
> yeah that's pretty ugly, and not acceptable if you're trying to use
> IPMI.

Indeed.

>> Everything becomes much more complicated with more recent kernels
>> (2.6.27 for example), where vlan filter is now enabled
>> unconditionally and I have to add the dummy IPMI vlan also on
>> no-vlan-enabled hosts to make it working. That makes it really
>> confusing.
>
> yeah, that's a not so good regression due to unconditionally turning on
> VLAN hardware offload.
>
>> So, is it possible to fix this? For example to change the driver to
>> read IPMI vlan id and add it to vlan filter regardless of current OS
>> configuration? Or maybe it is possible to prevent IPMI from
>> interferencing with the current driver's state?
>
> It might be possible to fix this.  The hardware doesn't *have* to
> support VLAN offload in hardware.  This would essentially leave all
> packets
> unmodified as they arrive.  We will definitely look
>
> So, do you intend that IPMI traffic should be on its own vlan?

Exactly. This configuration is very handy - most servers are connected to=
=20
one, untagged vlan and a host OS does not need to know about vlans at all=
.=20
IPMI is provided by one, dedicated, configured as an additional, tagged=20
vlan on hosts' ports.

>  Would this kind of configuration work?

Why not? Dell's BMC setup even allow to set it, on IBM servers for exampl=
e=20
I need to use ipmitool to do this, however there are different NICs=20
installed (bnx2). Having a dedicated vlan for IPMI service is very handy=20
as you may limit the traffic to one network and only allow to access it=20
from a very limited number of hosts. Plus, you don't need to worry about=20
IPMI configuration even when you move a server from one vlan to another.

> What if the IPMI traffic was=20
> *not* on a vlan but you had vlans enabled in your network?

Good question, I'll check this. However, as I stated above, I really woul=
d=20
like to keep IPMI on one, dedicated vlan. Having to spread IPMI over 40+=20
vlans connected to a number of different routers and keeping such a=20
configuration running looks like a very painful job. Please also note tha=
t=20
you remember about IPMI only when you have to use it, mostly in emergency=
=20
cases. Keeping it simple may even allow to make it accidentally usable at=
=20
that time. ;)

> Let me summarize, please correct me if I'm wrong:
> 0) you want to run IPMI traffic on its own VLAN
Yep.

> 1) 2.6.26 kernel with vlan enabled IPMI breaks doesn't work until drive=
r
> is loaded?

I have a non-modular kernel with the driver build statically into it. IPM=
I=20
obviously works before I booted a Linux kernel, not sure if making th=20
driver modular changes anything (I hope not). With the statically linked=20
driver I have:

<=3D2.6.26:
  - non-vlan host -> works
  - vlan host -> works with the dummy vlan

>=3D2.6.27:
  - works only with the dummy vlan

I'll retest with a modular configuration and let you know.

> 2) 2.6.27 kernel (which enables vlan stripping) breaks IPMI vlan traffi=
c
> until "dummy"
>   vlan is added with driver (on non-vlan hosts)

Exactly.

> I'm feeling a bit confused at this point, can you please describe what
> you want to do
> with both the host and the ipmi config?

I would like to use IPMI so I'll be able to power on/off or reset my=20
systems in case of problem with a host OS. There are number of things you=
=20
may do with a IP-enabled KVM but usually dealing with hardware buttons is=
=20
not one of them. ;)

> I'll have our lab see if they can reproduce this, I'm not even sure how
> many others have
> tried IPMI over VLAN.

Thanks, I very appreciate it.

Best regards,

 			Krzysztof Ol=EAdzki
---1144830174-1544616819-1225513221=:12764
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
---1144830174-1544616819-1225513221=:12764
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

---1144830174-1544616819-1225513221=:12764--
