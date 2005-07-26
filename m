From: P@draigBrady.com
Subject: Re: Linux Policy Routing-Based IDS Load Balancer HOWTO
Date: Tue, 26 Jul 2005 16:09:17 +0100
Message-ID: <42E6521D.6020601@draigBrady.com>
References: <200507260946.38894.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200507260946.38894.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeremy M. Guthrie wrote:
> Linux Policy Routing-Based IDS Load Balancer HOWTO

great thanks!

> 4.2.3.1  CPUs should only following one NIC.
>=20
>    If you look at the output below you can see that CPU0 is taking the=20
> interrupts for eth3.  CPU1 is taking interrupts for eth2 & eth0.  Optim=
ising=20
> any system relies on keep thrashing to a minimum.

I recommend you rename these interfaces throughout the doc,
and then you can refer to and write generic scripts against these
known names. For example:

ip link set dev eth2 name ids1
ip link set dev eth3 name ids2

>  As a result I highly=20
> recommend disable IRQ Balancing.
>=20
>    make menuconfig for your kernel config
>    Select "Processor type and features"
>    Disable "Enable kernel irq balancing"
>    Rebuild your kernel and reboot.
>=20
>    You will have to poke around /proc to set which CPU an interrupt bin=
ds to. =20
> Here is what was used to set the interrupt/CPU bindings down below:
>    echo 01 > /proc/irq/18/smp_affinity
>    echo 02 > /proc/irq/20/smp_affinity
>=20
>    The value used is expressed in powers of two.  ie. CPU3 would actual=
ly be=20
> 04.
>=20
>    cat /proc/interrupts
>            CPU0       CPU1
>   0: 3184569581 1789102599    IO-APIC-edge  timer
>   1:       1005        218    IO-APIC-edge  i8042
>   7:          0          0   IO-APIC-level  ohci_hcd
>   8:          1          1    IO-APIC-edge  rtc
>  12:        122         74    IO-APIC-edge  i8042
>  14:          2          0    IO-APIC-edge  ide0
>  18:  995373697       5139   IO-APIC-level  eth3
>  20:          2 1378253801   IO-APIC-level  eth2
>  27:    7542100    9352305   IO-APIC-level  eth0
>  28:    4150402   13187680   IO-APIC-level  aic7xxx
>  30:          0          0   IO-APIC-level  acpi
> NMI:          0          0
> LOC:  679927478  679903506
> ERR:          0
> MIS:          0

As an example of a generic script:

for iface in ids1 ids2; do
     int=3D`grep $iface\$ /proc/interrupts | cut -d: -f1`
     int=3D`echo $int` #strip whitespace
     [ "$iface" =3D "ids1" ] && mask=3D01 || mask=3D04
     echo $mask > /proc/irq/$int/smp_affinity
done

> 4.3.3  Basic scripts

I find "watch" very useful, for example:

watch -n1 `ethtool -S ids1`

--=20
P=C3=A1draig Brady - http://www.pixelbeat.org
--
