From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/5] net: socket bind to file descriptor introduced
Date: Wed, 15 Aug 2012 12:49:28 -0700
Message-ID: <87a9xwc4vr.fsf@xmission.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120815161141.7598.16682.stgit@localhost.localdomain>
	(Stanislav Kinsbursky's message of "Wed, 15 Aug 2012 20:21:56 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Thinking about this a little more I have serious reservations about this
approach.

Today you are not allowed to bind to an address unless mknod for that
file succeeds.  Your patch totally changes those semantics.

Name length limitation does not seeme to justify this at all.

It is possible today to trivially change into a directory and
bind or connect to what would be a long absolute path.

There is also the trick of getting a shorter directory name using
/proc/self/fd if you are threaded and can't change the directory.

The obvious choices at this point are
- Teach bind and connect and af_unix sockets to take longer AF_UNIX
  socket path names.

- introduce sockaddr_fd that can be applied to AF_UNIX sockets,
  and teach unix_bind and unix_connect how to deal with a second type of sockaddr.
  struct sockaddr_fd { short fd_family; short pad; int fd; };

- introduce sockaddr_unix_at that takes a directory file descriptor
  as well as a unix path, and teach unix_bind and unix_connect to deal with a
  second sockaddr type.
  struct sockaddr_unix_at { short family; short pad; int dfd; char path[102]; }
  AF_UNIX_AT

I don't know what the implications of for breaking connect up into 3
system calls and changing the semantics are and I would really rather
not have to think about it.

But it certainly does not look to me like you introduce new systems
calls to do what you want.

Eric
