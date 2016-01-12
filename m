From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 18:19:49 +0100
Message-ID: <1452619189.18559.83.camel@v3.sk>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
	 <8166.1452616452@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8166.1452616452@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 08:34 -0800, Jay Vosburgh wrote:
> Lubomir Rintel <lkundrak@v3.sk> wrote:
>=20
> > The devices can be created at run-time for quite some time already
> > and the
> > load-time device creation collides with attempts to create the
> > device of
> > the same name:
> >=20
> > =C2=A0# rmmod bonding
> > =C2=A0# ip link add bond0 type bond
> > =C2=A0RTNETLINK answers: File exists
> >=20
> > This is pretty much the same situation as was with the block loop
> > devices
> > which was solved by adding a build-time configuration that the
> > distributions could use as they deem fit while keeping the default
> > for
> > compatibility.
>=20
> 	I agree this is annoying, but I would expect distros to leave
> this set to 1 (for backwards compatibility with scripts that
> "modprobe
> bonding" then assume bond0 exists).=C2=A0=C2=A0This leaves the proble=
m in place
> for the vast majority of users.

It's still an improvement to let the distributions decide if they're
keeping "ip link add" broken or possibly affecting the scripts. Given
the "modprobe bonding" didn't guarantee the bond0 bevice will be around
at least since 2007 it think it's very reasonable for the distros to
turn this off.

The network management tooling shipped with Fedora (both the legacy
network service and NetworkManager) always did the right thing, be it
writing to /sys/class/net/bonding_masters or adding the link via
rtnetlink.

Moreover, NetworkManager already specifically calls "modprobe bonding
maxbonds=3D0" to avoid the creation of an extra "bond0" device (which
coincidentally also breaks the naively written scripts if they are
executed after NM creates a bond).

There's also a good prior art to this; as Daniel Borkmann pointed out
in [1], Fedora ships a kernel with CONFIG_BLK_DEV_LOOP_MIN_COUNT=3D0
happily for 4 releases already.

[1]=C2=A0http://marc.info/?l=3Dlinux-netdev&m=3D145261483331891&w=3D2

> 	Is there a reasonable way to resolve this that would actually
> fix things for regular distro kernel users?

Depends on the definition of reasonable. Not being very familiar with
the rtnetlink code, it would perhaps be possible to create some half-
finished "bond0" device before doing a request_module(), so that the
subsequently loaded module wouldn't take it over.

It doesn't sound like a good idea to me as it would still cause an
extra "bond0" device in case the user chooses a different name and the
workarounds such as the one NetworkManager uses would still be
necessary.

>=20
> 	-J
>=20
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com

Lubo
