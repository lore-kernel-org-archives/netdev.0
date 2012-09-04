From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Tue, 4 Sep 2012 15:00:07 -0400
Message-ID: <20120904190007.GB29369@fieldses.org>
References: <20120815161141.7598.16682.stgit@localhost.localdomain>
 <87y5lf7d37.fsf@xmission.com>
 <50320EE5.10307@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"thierry.reding@avionic-design.de" <thierry.reding@avionic-design.de>,
	"bfields@redhat.com" <bfields@redhat.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"devel@ope
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50320EE5.10307@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 20, 2012 at 02:18:13PM +0400, Stanislav Kinsbursky wrote:
> 16.08.2012 07:03, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >Stanislav Kinsbursky <skinsbursky@parallels.com> writes:
> >
> >>This patch set introduces new socket operation and new system call:
> >>sys_fbind(), which allows to bind socket to opened file.
> >>File to bind to can be created by sys_mknod(S_IFSOCK) and opened by
> >>open(O_PATH).
> >>
> >>This system call is especially required for UNIX sockets, which has=
 name
> >>lenght limitation.
> >>
> >>The following series implements...
> >
> >Hmm.  I just realized this patchset is even sillier than I thought.
> >
> >Stanislav is the problem you are ultimately trying to solve nfs clie=
nts
> >in a container connecting to the wrong user space rpciod?
> >
>=20
> Hi, Eric.
> The problem you mentioned was the reason why I started to think about=
 this.
> But currently I believe, that limitations in unix sockets connect or
> bind should be removed, because it will be useful it least for CRIU
> project.
>=20
> >Aka net/sunrpc/xprtsock.c:xs_setup_local only taking an absolute pat=
h
> >and then creating a delayed work item to actually open the unix doma=
in
> >socket?
> >
> >The straight correct and straight forward thing to do appears to be:
> >- Capture the root from current->fs in xs_setup_local.
> >- In xs_local_finish_connect change current->fs.root to the captured
> >   version of root before kernel_connect, and restore current->fs.ro=
ot
> >   after kernel_connect.
> >
> >It might not be a bad idea to implement open on unix domain sockets =
in
> >a filesystem as create(AF_LOCAL)+connect() which would allow you to
> >replace __sock_create + kernel_connect with a simple file_open_root.
> >
>=20
> I like the idea of introducing new family (AF_LOCAL_AT for example)
> and new sockaddr for connecting or binding from specified root. The
> only thing I'm worrying is passing file descriptor to unix bind or
> connect routine. Because this approach doesn't provide easy way to
> use such family and sockaddr in kernel (like in NFS example).
>=20
> >But I think the simple scheme of:
> >struct path old_root;
> >old_root =3D current->fs.root;
> >kernel_connect(...);
> >current->fs.root =3D old_root;
> >
> >Is more than sufficient and will remove the need for anything
> >except a purely local change to get nfs clients to connect from
> >containers.
> >
>=20
> That was my first idea.

So is this what you're planning on doing now?

> And probably it would be worth to change all
> fs_struct to support sockets with relative path.
> What do you think about it?

I didn't understand the question.  Are you suggesting that changes to
fs_struct would be required to make this work?  I don't see why.

--b.
