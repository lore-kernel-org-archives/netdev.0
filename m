From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Wed, 15 Aug 2012 20:03:24 -0700
Message-ID: <87y5lf7d37.fsf@xmission.com>
References: <20120815161141.7598.16682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: tglx@linutronix.de, mingo@redhat.com, davem@davemloft.net,
	hpa@zytor.com, thierry.reding@avionic-design.de,
	bfields@redhat.com, eric.dumazet@gmail.com, xemul@parallels.com,
	neilb@suse.de, netdev@vger.kernel.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	akpm@linux-foundation.org, tim.c.chen@linux.intel.com,
	devel@openvz.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51003 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab2HPDDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 23:03:36 -0400
In-Reply-To: <20120815161141.7598.16682.stgit@localhost.localdomain>
	(Stanislav Kinsbursky's message of "Wed, 15 Aug 2012 20:21:56 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislav Kinsbursky <skinsbursky@parallels.com> writes:

> This patch set introduces new socket operation and new system call:
> sys_fbind(), which allows to bind socket to opened file.
> File to bind to can be created by sys_mknod(S_IFSOCK) and opened by
> open(O_PATH).
>
> This system call is especially required for UNIX sockets, which has name
> lenght limitation.
>
> The following series implements...

Hmm.  I just realized this patchset is even sillier than I thought.

Stanislav is the problem you are ultimately trying to solve nfs clients
in a container connecting to the wrong user space rpciod?

Aka net/sunrpc/xprtsock.c:xs_setup_local only taking an absolute path
and then creating a delayed work item to actually open the unix domain
socket?

The straight correct and straight forward thing to do appears to be:
- Capture the root from current->fs in xs_setup_local.
- In xs_local_finish_connect change current->fs.root to the captured
  version of root before kernel_connect, and restore current->fs.root
  after kernel_connect.

It might not be a bad idea to implement open on unix domain sockets in
a filesystem as create(AF_LOCAL)+connect() which would allow you to
replace __sock_create + kernel_connect with a simple file_open_root.

But I think the simple scheme of:
struct path old_root;
old_root = current->fs.root;
kernel_connect(...);
current->fs.root = old_root;

Is more than sufficient and will remove the need for anything
except a purely local change to get nfs clients to connect from
containers.

Eric
