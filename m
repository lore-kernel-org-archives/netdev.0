From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Fri, 11 Sep 2009 16:32:49 +0200
Message-ID: <200909111632.50477.agruen@suse.de>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_S+lqKToL9s78RMI"
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_S+lqKToL9s78RMI
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

The patches did apply and build against next-20090910. I wrote a small user-
space utility for testing (attached); see how painless the socket interface 
is. The patches seem to be working well, except that some required 
functionality is missing still.

Currently, the CAP_NET_RAW capability is needed for being able to create 
watches. This seems too strict to me; I don't see why I shouldn't be able to 
watch my own files, or files which I have read access to (like inotify).

There are some actions like creating hardlinks in directories or removing 
files which don't trigger events. From a user point of view, I would prefer to 
receive those events as well. (I notice that it's not easy to to pass file 
descriptors to listeners for those events.)

Thanks,
Andreas

--Boundary-00=_S+lqKToL9s78RMI
Content-Type: text/x-csrc;
  charset="UTF-8";
  name="fanotify.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="fanotify.c"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <inttypes.h>
#include <stdbool.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "linux/fanotify.h"

int watch_inode(int fan_fd, const char *path, uint32_t mask)
{
	struct fanotify_so_inode_mark mark;

	memset(&mark, 0, sizeof(mark));
	mark.fd = open(path, 0);
	if (mark.fd == -1)
		return -1;
	mark.mask = mask;
	if (setsockopt(fan_fd, SOL_FANOTIFY, FANOTIFY_SET_MARK,
		       &mark, sizeof(mark)) != 0)
		return -1;
	close(mark.fd);
	return 0;
}

void synopsis(const char *progname, int status)
{
	FILE *file = status ? stderr : stdout;

	fprintf(file, "USAGE: %s [-cg] [-o {open,close,access,modify}] file ...\n",
		progname);
	exit(status);
}

int main(int argc, char *argv[])
{
	int opt;
	int fan_fd;
	uint32_t fan_mask = FAN_OPEN | FAN_CLOSE | FAN_ACCESS | FAN_MODIFY;
	bool opt_child = false, opt_global = false;
	ssize_t len;
	struct fanotify_addr addr;
	char buf[4096];
#ifdef WITH_PID
	pid_t pid;
#endif

	while ((opt = getopt(argc, argv, "o:cgh")) != -1) {
		switch(opt) {
			case 'o': {
				char *str, *tok;

				fan_mask = 0;
				str = optarg;
				while ((tok = strtok(str, ",")) != NULL) {
					str = NULL;
					if (strcmp(tok, "open") == 0)
						fan_mask |= FAN_OPEN;
					else if (strcmp(tok, "close") == 0)
						fan_mask |= FAN_CLOSE;
					else if (strcmp(tok, "access") == 0)
						fan_mask |= FAN_ACCESS;
					else if (strcmp(tok, "modify") == 0)
						fan_mask |= FAN_MODIFY;
					else
						synopsis(argv[0], 1);
				}
				break;
			}
			case 'c':
				opt_child = true;
				break;
			case 'g':
				opt_global = true;
				break;
			case 'h':
				synopsis(argv[0], 0);
			default:  /* '?' */
				synopsis(argv[0], 1);
		}
	}
	if (optind == argc && !opt_global)
		synopsis(argv[0], 1);

	if (opt_child)
		fan_mask |= FAN_EVENT_ON_CHILD;

	memset(&addr, 0, sizeof(addr));
	addr.family = AF_FANOTIFY;
	addr.priority = 32768;
	addr.mask = opt_global ? fan_mask : 0;

	fan_fd = socket(PF_FANOTIFY, SOCK_RAW, 0);
	if (fan_fd == -1)
		goto fail;
	if (bind(fan_fd, (struct sockaddr *)&addr, sizeof(addr)) != 0)
		goto fail;

	for (; optind < argc; optind++)
		if (watch_inode(fan_fd, argv[optind], fan_mask) != 0)
			goto fail;

#if WITH_PID
	pid = getpid();
#endif
	while ((len = recv(fan_fd, buf, sizeof(buf), 0)) > 0) {
		struct fanotify_event_metadata *metadata;

		metadata = (void *)buf;
		while(FAN_EVENT_OK(metadata, len)) {
			struct stat st;

#if WITH_PID
			if (metadata->pid == pid)
				goto skip;
#endif

			if (metadata->fd >= 0) {
				char path[PATH_MAX];

				sprintf(path, "/proc/self/fd/%d", metadata->fd);
				if (readlink(path, path, sizeof(path)) == -1)
					goto fail;
				printf("%s:", path);
			} else
				printf("?:");

#if WITH_PID
			if (metadata->pid >= 0)
				printf(" pid=%ld", metadata->pid);
#endif

			if (metadata->mask & FAN_ACCESS)
				printf(" access");
			if (metadata->mask & FAN_OPEN)
				printf(" open");
			if (metadata->mask & FAN_MODIFY)
				printf(" modify");
			if (metadata->mask & FAN_CLOSE) {
				if (metadata->mask & FAN_CLOSE_WRITE)
					printf(" close(writable)");
				else
					printf(" close");
			}
			printf("\n");

		skip:
			if (metadata->fd >= 0 && close(metadata->fd) != 0)
				goto fail;
			metadata = FAN_EVENT_NEXT(metadata, len);
		}
	}
	if (len < 0)
		goto fail;
	return 0;

fail:
	fprintf(stderr, "%s\n", strerror(errno));
	return 1;
}

--Boundary-00=_S+lqKToL9s78RMI--
