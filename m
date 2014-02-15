From: Borislav Petkov <bp@alien8.de>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Date: Sun, 16 Feb 2014 00:25:08 +0100
Message-ID: <20140215232508.GB4508@pd.tnic>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
 <20140215203015.GA4528@pd.tnic>
 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"mlindner@marvell.com" <mlindner@marvell.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: John <da_audiophile@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 15, 2014 at 01:04:22PM -0800, John wrote:
> Thanks for the reply, Boris. =C2=A0The .config is unmodified
> from the Arch Distro default for 3.13.3-1 which can be found
> here:=C2=A0http://pastebin.com/LPGZ8ZqA

Yep, it is that struct net *net argument to put_pipe_version() which is=
 NULL:

  12:   55                      push   %ebp
  13:   89 e5                   mov    %esp,%ebp
  15:   56                      push   %esi
  16:   53                      push   %ebx
  17:   3e 8d 74 26 00          lea    %ds:0x0(%esi,%eiz,1),%esi
  1c:   8b 1d 28 e9 a3 f8       mov    0xf8a3e928,%ebx
  22:   89 c6                   mov    %eax,%esi
  24:   e8 59 64 5f c8          call   0xc85f6482
  29:   85 db                   test   %ebx,%ebx
  2b:*  8b 86 58 08 00 00       mov    0x858(%esi),%eax         <-- tra=
pping instruction

put_pipe_version:
	pushl	%ebp	#
	movl	%esp, %ebp	#,
	pushl	%esi	#
	pushl	%ebx	#
	call	mcount
	movl	sunrpc_net_id, %ebx	# sunrpc_net_id, sunrpc_net_id.130
	movl	%eax, %esi	# net, net
	call	__rcu_read_lock	#
	testl	%ebx, %ebx	# sunrpc_net_id.130
	movl	2136(%esi), %eax	# MEM[(struct net_generic * const *)net_4(D) + 2=
136B], ng <-- trapping insn


	[ 137.689996] ESI: 00000000 EDI: f56efc00 EBP: f568fee8 ESP: f568fee0
			   ^^^^^^^^

Here's the c/asm interleaved version:

static void put_pipe_version(struct net *net)
{
     d80:       55                      push   %ebp
     d81:       89 e5                   mov    %esp,%ebp
     d83:       56                      push   %esi
     d84:       53                      push   %ebx
     d85:       e8 fc ff ff ff          call   d86 <put_pipe_version+0x=
6>
                        d86: R_386_PC32 mcount
        struct sunrpc_net *sn =3D net_generic(net, sunrpc_net_id);
     d8a:       8b 1d 00 00 00 00       mov    0x0,%ebx
                        d8c: R_386_32   sunrpc_net_id
        spin_unlock(&pipe_version_lock);
        return ret;
}

static void put_pipe_version(struct net *net)
{
     d90:       89 c6                   mov    %eax,%esi
 * block, but only when acquiring spinlocks that are subject to priorit=
y
 * inheritance.
 */
static inline void rcu_read_lock(void)
{
        __rcu_read_lock();
     d92:       e8 fc ff ff ff          call   d93 <put_pipe_version+0x=
13>
                        d93: R_386_PC32 __rcu_read_lock
        struct net_generic *ng;
        void *ptr;

        rcu_read_lock();
        ng =3D rcu_dereference(net->gen);
        BUG_ON(id =3D=3D 0 || id > ng->len);
     d97:       85 db                   test   %ebx,%ebx
{
        struct net_generic *ng;
        void *ptr;

        rcu_read_lock();
        ng =3D rcu_dereference(net->gen);
     d99:       8b 86 58 08 00 00       mov    0x858(%esi),%eax			<-- t=
rapping insn


I guess you could avoid the crash if you did

	if (!net)
		return;

in put_pipe_version() but this hardly is the right solution. Someone
else has to make sense of this thing, not me. :-)

HTH.

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
