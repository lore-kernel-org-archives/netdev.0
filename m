From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 11:36:47 -0800
Message-ID: <11832.1452627407@famine>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk> <8166.1452616452@famine> <1452619189.18559.83.camel@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1452619189.18559.83.camel@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lubomir Rintel <lkundrak@v3.sk> wrote:

>On Tue, 2016-01-12 at 08:34 -0800, Jay Vosburgh wrote:
>> Lubomir Rintel <lkundrak@v3.sk> wrote:
>>=20
>> > The devices can be created at run-time for quite some time already
>> > and the
>> > load-time device creation collides with attempts to create the
>> > device of
>> > the same name:
>> >=20
>> > =C2=A0# rmmod bonding
>> > =C2=A0# ip link add bond0 type bond
>> > =C2=A0RTNETLINK answers: File exists
>> >=20
>> > This is pretty much the same situation as was with the block loop
>> > devices
>> > which was solved by adding a build-time configuration that the
>> > distributions could use as they deem fit while keeping the default
>> > for
>> > compatibility.
>>=20
>> 	I agree this is annoying, but I would expect distros to leave
>> this set to 1 (for backwards compatibility with scripts that
>> "modprobe
>> bonding" then assume bond0 exists).=C2=A0=C2=A0This leaves the probl=
em in place
>> for the vast majority of users.
>
>It's still an improvement to let the distributions decide if they're
>keeping "ip link add" broken or possibly affecting the scripts. Given
>the "modprobe bonding" didn't guarantee the bond0 bevice will be aroun=
d
>at least since 2007 it think it's very reasonable for the distros to
>turn this off.

	This looks to me like one of those false "let the distros
decide" choices, as they'll likely all end up with the same settings, s=
o
most users are going to see the same behaviors.

	If different distros set the various Kconfig options from this
patch series to a mish-mash of different settings, then it's not really
much of an improvement, either.  Anything cross-distro would still have
to work all ways, even if it keeps track of the kernel version.

>The network management tooling shipped with Fedora (both the legacy
>network service and NetworkManager) always did the right thing, be it
>writing to /sys/class/net/bonding_masters or adding the link via
>rtnetlink.

	And this is true for the Debian / Ubuntu scripts as well.

>Moreover, NetworkManager already specifically calls "modprobe bonding
>maxbonds=3D0" to avoid the creation of an extra "bond0" device (which
>coincidentally also breaks the naively written scripts if they are
>executed after NM creates a bond).

	The scripts I'm thinking of are not system provided, but
administrator or vendor created scripts that follow some of the now ver=
y
old instructions in the bonding.txt documentation, e.g.,

[... from bonding.txt ...]
        For example, if you wanted to make a simple bond of two e100
devices (presumed to be eth0 and eth1), and have it persist across
reboots, edit the appropriate file (/etc/init.d/boot.local or
/etc/rc.d/rc.local), and add the following:

modprobe bonding mode=3Dbalance-alb miimon=3D100
modprobe e100
ifconfig bond0 192.168.1.1 netmask 255.255.255.0 up
ip link set eth0 master bond0
ip link set eth1 master bond0

	They're probably (hopefully) old, but there are likely still
some lurking out there somewhere.  Whether these would ever be upgraded
to current kernels is a separate question; I've not seen scripts like
this in production use for a few years, but they were common at one
time.

>There's also a good prior art to this; as Daniel Borkmann pointed out
>in [1], Fedora ships a kernel with CONFIG_BLK_DEV_LOOP_MIN_COUNT=3D0
>happily for 4 releases already.
>
>[1]=C2=A0http://marc.info/?l=3Dlinux-netdev&m=3D145261483331891&w=3D2

	Ok, if it's been done before and apparently went just fine, then
the real intent here is to not auto-create bond0 (and the other devices
in the other patches of the series) in distro kernels, correct?  I.e.,
have the "count" values all set to zero, so that the module load doesn'=
t
ever auto-create any of these devices.

	So, why not simply make the change (to not auto-create)
unilaterally, without the complexity of a set of Kconfig options that
are meant to always be overridden?

	I'll even help you here by shooting at my own argument: if the
old-style bonding scripts from the days of yore would already break if
brought forward from, say, RHEL 3 or 4 (about the last place I recall
seeing them) to something current, then is there any reason not to
simply make the bonding max_bonds=3D0 by default instead of 1?  Even th=
en,
the administrator for a system could add "max_bonds=3D1" to a
/etc/modprobe.d/bonding.conf to restore the original behavior.

>> 	Is there a reasonable way to resolve this that would actually
>> fix things for regular distro kernel users?
>
>Depends on the definition of reasonable. Not being very familiar with
>the rtnetlink code, it would perhaps be possible to create some half-
>finished "bond0" device before doing a request_module(), so that the
>subsequently loaded module wouldn't take it over.
>
>It doesn't sound like a good idea to me as it would still cause an
>extra "bond0" device in case the user chooses a different name and the
>workarounds such as the one NetworkManager uses would still be
>necessary.

	Yah, any sort of hack in iproute is going to be ugly; I hadn't
really thought it through earlier.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
