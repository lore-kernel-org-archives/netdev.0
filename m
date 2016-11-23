From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: sendfile from 9p fs into af_alg
Date: Tue, 22 Nov 2016 19:58:29 -0800
Message-ID: <20161123035827.GA43786@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al,

it seems the following commit 523ac9afc73a ("switch default_file_splice_read() to use of pipe-backed iov_iter")
breaks sendfile from 9p fs into af_alg socket.
sendfile into af_alg is used by iproute2/tc.
I'm not sure whether it's 9p or crypto or vfs problem, but happy to test any patches.

The following program is a reduced test from iproute2.
On broken kernels it fails as:
$ ./a.out some_file
Error from sendfile (8192 vs 9624 bytes): Success

It seems to work fine when 'some_file' is on ext4 or tmpfs, so could be 9p related.

Thanks
------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <sys/vfs.h>
#include <sys/mount.h>
#include <sys/syscall.h>
#include <sys/sendfile.h>
#include <sys/resource.h>

#include <linux/if_alg.h>

#include <arpa/inet.h>

#ifndef AF_ALG
#define AF_ALG 38
#endif

static int obj_hash(const char *object, uint8_t *out, size_t len)
{
	struct sockaddr_alg alg = {
		.salg_family	= AF_ALG,
		.salg_type	= "hash",
		.salg_name	= "sha1",
	};
	int ret, cfd, ofd, ffd;
	struct stat stbuff;
	ssize_t size;

	if (!object || len != 20)
		return -EINVAL;

	cfd = socket(AF_ALG, SOCK_SEQPACKET, 0);
	if (cfd < 0) {
		fprintf(stderr, "Cannot get AF_ALG socket: %s\n",
			strerror(errno));
		return cfd;
	}

	ret = bind(cfd, (struct sockaddr *)&alg, sizeof(alg));
	if (ret < 0) {
		fprintf(stderr, "Error binding socket: %s\n", strerror(errno));
		goto out_cfd;
	}

	ofd = accept(cfd, NULL, 0);
	if (ofd < 0) {
		fprintf(stderr, "Error accepting socket: %s\n",
			strerror(errno));
		ret = ofd;
		goto out_cfd;
	}

	ffd = open(object, O_RDONLY);
	if (ffd < 0) {
		fprintf(stderr, "Error opening object %s: %s\n",
			object, strerror(errno));
		ret = ffd;
		goto out_ofd;
	}

	ret = fstat(ffd, &stbuff);
	if (ret < 0) {
		fprintf(stderr, "Error doing fstat: %s\n",
			strerror(errno));
		goto out_ffd;
	}

	size = sendfile(ofd, ffd, NULL, stbuff.st_size);
	if (size != stbuff.st_size) {
		fprintf(stderr, "Error from sendfile (%zd vs %zu bytes): %s\n",
			size, stbuff.st_size, strerror(errno));
		ret = -1;
		goto out_ffd;
	}

	size = read(ofd, out, len);
	if (size != len) {
		fprintf(stderr, "Error from read (%zd vs %zu bytes): %s\n",
			size, len, strerror(errno));
		ret = -1;
	} else {
		ret = 0;
	}
out_ffd:
	close(ffd);
out_ofd:
	close(ofd);
out_cfd:
	close(cfd);
	return ret;
}

int main(int ac, char **av)
{
	uint8_t hash[20] = {};

	if (ac != 2) {
		fprintf(stderr, "%s file\n", av[0]);
		return 1;
	}
	obj_hash(av[1], hash, sizeof(hash));
	printf("hash %llx\n", *(long long *)hash);
	return 0;
}
