From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/6] SUNRPC: make RPC clients use network-namespace-aware
 PipeFS routines
Date: Wed, 23 Nov 2011 21:58:25 +0400
Message-ID: <4ECD3441.80405@parallels.com>
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6> <20111123163632.GB30672@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111123163632.GB30672@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

23.11.2011 20:36, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, Nov 23, 2011 at 02:51:10PM +0300, Stanislav Kinsbursky wrote:
>> This patch set was created in context of clone of git
>> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
>> tag: v3.1
>>
>> This patch set depends on previous patch sets titled:
>> 1) "SUNRPC: initial part of making pipefs work in net ns"
>> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
>>
>> This patch set is a first part of reworking SUNPRC PipeFS users.
>> It makes SUNRPC clients using PipeFS nofitications for directory and=
 GSS pipes
>> dentries creation. With this patch set RPC clients and GSS auth crea=
tions
>> routines doesn't force SUNRPC PipeFS mount point creation which actu=
ally means,
>> that they now can work without PipeFS dentries.
>
> I'm not following very well.  (My fault, I haven't been paying
> attention.)  Could you summarize the itended behavior of pipefs after
> all this is done?
>
> So there's a separate superblock (and separate dentries) for each
> namespace?
>

Yes, you right.
So, here is a brief summary of what will be at the end:

1) PipeFS superblock will be per net ns.

2) Superblock holds net ns, which is taken from current. Struct net wil=
l have=20
link ot pipefs superblock (it can be NULL, if PipeFS wasn't mounted yet=
 or=20
already unmounted).

3) Notifications will be send on superblock creation and destruction.

4) All kernel mount point creation and destruction calls (rpc_get_mount=
() and=20
rpc_put_mount()) will be removed. I.e. this superblock will be created =
only from=20
user-space.

5) Kernel pipes and dentries will be created or destroyed:
1. During per-net operations (only for static NFS stuff: dns_resolve ca=
che, pnfs=20
blocklayout and idmap pipes).
2. On notification events (all directories, files and pipes in proper=20
callbacks). Notification subscribers:
a. rpc clients (responsible for client dentries and gss pipes creation)=
,
b. nfs clients (responsible nfs idmap pipes),
c. nfs dns_resolve cache,
d. pnfs blocklayout pipes,

6) PipeFS dentries creation logic:
a) All directories and files creators - will try to create them as usua=
l. But if=20
fail - then no problem here. I.e. dentries will be created on PipeFS mo=
unt=20
notification call.
b) Pipes creators - will create new structure rpc_pipe (all pipe stuff =
from rpc=20
inode) nad then try to create pipe denties. If fail - then, again, no p=
roblem.=20
Dentries will be be created on PipeFS mount notification call.


Almost all (exept 5.2.b - forgot about it during debasing and resending=
) is done=20
and ready to send.

> What decides which clients are visible in which network namespaces?
>

Clients dentries will be created in proper superblock from the beginnin=
g. I.e.=20
rpc clients transports have struct net reference. NFS clients will have=
 such=20
reference too. Struct net will have reference to pipefs superblock.
Currently, for dentry creation all we need is parent dentry. Some of cr=
eators=20
(like GSS pipes) takes parent dentry from associated struct (like rpc_c=
lnt). For=20
others parent dentry can be found by simple d_lookup() starting from sb=
->root=20
(reminder: sb can be taken from net).


--=20
Best regards,
Stanislav Kinsbursky
