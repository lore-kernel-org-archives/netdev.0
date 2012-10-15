From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v6 02/10] ipc: "use key as id" functionality for resource get system call introduced
Date: Mon, 15 Oct 2012 12:47:40 -0700
Message-ID: <87r4ozecv7.fsf@xmission.com>
References: <20121015155800.28348.23561.stgit@localhost.localdomain>
	<20121015155946.28348.47885.stgit@localhost.localdomain>
	<87lif7frt8.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com,
	will.deacon@arm.com, dhowells@redhat.com, manfred@colorfullife.com,
	hughd@google.com, jmorris@namei.org, mtk.manpages@gmail.com,
	kosaki.motohiro@jp.fujitsu.com, paulmck@linux.vnet.ibm.com,
	sds@tycho.nsa.gov, devel@openvz.org, a.p.zijlstra@chello.nl,
	cmetcalf@tilera.com, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	eparis@parisplace.org, tglx@linutronix.de,
	jitendra.kalsaria@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, casey@schaufler-ca.com
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <87lif7frt8.fsf@xmission.com> (Eric W. Biederman's message of
	"Mon, 15 Oct 2012 12:39:31 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ebiederm@xmission.com (Eric W. Biederman) writes:

> Stanislav Kinsbursky <skinsbursky@parallels.com> writes:
>
>> This patch introduces new IPC resource get request flag IPC_PRESET, which
>> should be interpreted as a request to try to allocate IPC slot with number,
>> starting from value resented by key. IOW, kernel will try
>> allocate new segment in specified slot.
>>
>> Note: if desired slot is not emply, then next free slot will be used.
>
> This way of handling things is pretty nasty.
>
> - You don't fail if the requested id is not available.
> - You don't allow assigning the key (which leads to the need to change
>   the key in later patches).  Changing the creator uid and creator
>   gid and key is semantically ugly.
>
> It would be much cleaner if you could instead add IPC_PRESET and then
> extend the definition of the creation functions all by one argument.
>
> aka
> int msgget(key_t key, int msgflg, int id);
> int semget(key_t key, int nsems, int semflg, int id);
> int shmget(key_t key, size_t size, int shmflg, int id);
>
> Where the extra id argument is ignored unless IPC_PRESET is specified.
>
> Also msgget, semget, and shmget should fail if unregconized flags are
> passed in.  That ipcget doesn't do that today is bizarre.

Hmm.  Come to think of it I don't see why you need to set the id at all.
We are using an idr allocator which effectively offers the semantics
that the lowest available id will be allocated.  The same semantics we
have for file descriptors.

So it should be possible at least for the first pass at
checkpoint/restart to implement the restoration of sysv ipc without
IPC_PRESET at all.

So IPC_PRESET should just be an optimization, not a necessary feature.

That makes all of your code go away except the message queue
peeking, which seems much less intrusive for the first pass.

Eric
