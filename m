From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip link: fix up bond/bridge slave id
Date: Tue, 6 Sep 2016 11:31:24 +0300
Message-ID: <7515B4FB-81C4-4B70-8DCF-AD2D88097C8C@cumulusnetworks.com>
References: <1473147861-30544-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Jiri Pirko <jiri@resnulli.us>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38515 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755592AbcIFIbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 04:31:25 -0400
Received: by mail-wm0-f48.google.com with SMTP id 1so175403345wmz.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 01:31:24 -0700 (PDT)
In-Reply-To: <1473147861-30544-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 6, 2016, at 10:44 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
>=20
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
> ip/iplink_bond_slave.c   | 2 +-
> ip/iplink_bridge_slave.c | 2 +-
> 2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
> index 9c60dea..8a3104b 100644
> --- a/ip/iplink_bond_slave.c
> +++ b/ip/iplink_bond_slave.c
> @@ -130,7 +130,7 @@ static void bond_slave_print_help(struct link_util =
*lu, int argc, char **argv,
> }
>=20
> struct link_util bond_slave_link_util =3D {
> -	.id		=3D "bond",
> +	.id		=3D "bond_slave",
> 	.maxattr	=3D IFLA_BOND_SLAVE_MAX,
> 	.print_opt	=3D bond_slave_print_opt,
> 	.parse_opt	=3D bond_slave_parse_opt,
> diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
> index a44d4e4..58563e0 100644
> --- a/ip/iplink_bridge_slave.c
> +++ b/ip/iplink_bridge_slave.c
> @@ -293,7 +293,7 @@ static void bridge_slave_print_help(struct =
link_util *lu, int argc, char **argv,
> }
>=20
> struct link_util bridge_slave_link_util =3D {
> -	.id		=3D "bridge",
> +	.id		=3D "bridge_slave",
> 	.maxattr	=3D IFLA_BRPORT_MAX,
> 	.print_opt	=3D bridge_slave_print_opt,
> 	.parse_opt	=3D bridge_slave_parse_opt,
> --=20
> 2.5.5
>=20

NAK, this will actually force the iplink slave logic to always lookup =
the linkutil symbol. Please check iplink.c and how slave linkutil =
structs are found.
The first part of the =E2=80=9Cbridge/bond_slave=E2=80=9D is extracted =
from the requested type (e.g. bond_slave -> bond) and is
looked up with the slave flag set to true, in case that fails the symbol =
(%s_slave_link_util) is looked up and added to the
linkutil list for later use, but in this case we can end up with =
linkutil list head pointing to itself (the same slave link util added =
twice if f.e. we have
more than 1 slave of that type) and since it doesn=E2=80=99t match - =
we=E2=80=99ll loop forever.

Just try adding 2 or more bond slaves with this patch and then do:
ip -d link show
