From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH 0/3] crypto: algif - change algif_skcipher to be asynchronous
Date: Mon, 02 Feb 2015 07:03:02 -0800
Message-ID: <54CF91A6.2020100@intel.com>
References: <20150129231338.25156.65450.stgit@tstruk-mobl1> <1653087.XMGL7JlhQx@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, qat-linux@intel.com,
	linux-kernel@vger.kernel.org
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1653087.XMGL7JlhQx@tachyon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2015 10:31 AM, Stephan Mueller wrote:
> Hi Tadeusz,
> 
>> > The way the algif_skcipher works currently is that on sendmsg/sendpage it
>> > builds an sgl for the input data and then on read/recvmsg it sends the job
>> > for encryption putting the user to sleep till the data is processed.
>> > This way it can only handle one job at a given time.
>> > To be able to fuly utilize the potential of existing crypto hardware
>> > accelerators it is required to submit multiple jobs in asynchronously.
>> > First patch enables asynchronous read and write on socket.
>> > Second patch enables af_alg sgl to be linked.
>> > Third patch implement asynch read for skcipher.
> Do you have a code fragment on how to test that patch? I would like to see 
> whether I can test that with my libkcapi.

Hi Stephan,
This is what I'm using.

#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <linux/types.h>
#include <linux/aio_abi.h>
#include <sys/syscall.h>
#include <sys/uio.h>

#define SOL_ALG 279

#define SPLICE_F_GIFT	(0x08)	/* pages passed in are a gift */
struct sockaddr_alg {
	__u16	salg_family;
	__u8	salg_type[14];
	__u32	salg_feat;
	__u32	salg_mask;
	__u8	salg_name[64];
};
struct af_alg_iv {
	__u32	ivlen;
	__u8	iv[0];
};
/* Socket options */
#define ALG_SET_KEY			1
#define ALG_SET_IV			2
#define ALG_SET_OP			3
#define ALG_SET_AEAD_ASSOCLEN		4
#define ALG_SET_AEAD_AUTHSIZE		5

/* Operations */
#define ALG_OP_DECRYPT			0
#define ALG_OP_ENCRYPT			1

#define BUFFSIZE (4096)
//#define BUFFSIZE (4096)
#define PKGSIZE (4096)

#define INFLIGTHS 256
#define TO_SEND (1024 * 1024)
//#define OUT_OFFSET 2048;
//#define IN_OFFSET 4064;
#define OUT_OFFSET 0;
#define IN_OFFSET 0;

static char buf[BUFFSIZE] __attribute__((__aligned__(BUFFSIZE)));
static char *buf_out = buf;

static inline int io_setup(unsigned n, aio_context_t *ctx)
{
	return syscall(__NR_io_setup, n, ctx);
}

static inline int io_destroy(aio_context_t ctx)
{
	return syscall(__NR_io_destroy, ctx);
}

static inline int io_read(aio_context_t ctx, long n,  struct iocb **iocb)
{
	return syscall(__NR_io_submit, ctx, n, iocb);
}

static inline int io_getevents(aio_context_t ctx, long min, long max,
			struct io_event *events, struct timespec *timeout)
{
	return syscall(__NR_io_getevents, ctx, min, max, events, timeout);
}

static inline int eventfd(int n)
{
	return syscall(__NR_eventfd, n);
}

static int crypt_kernel(const char *key, char *oiv, int zcp)
{
	int opfd;
	int tfmfd;
	int efd;
	struct timespec timeout;
	fd_set rfds;
        struct timeval tv;
	struct sockaddr_alg sa = {
		.salg_family = AF_ALG,
		.salg_type = "skcipher",
		.salg_name = "cbc(aes)"
	};
	struct msghdr msg = {};
	struct cmsghdr *cmsg;
	char cbuf[CMSG_SPACE(4) + CMSG_SPACE(20)] = {};
	struct aes_iv {
		__u32 len;
		__u8 iv[16];
	} *iv;
	struct iovec iov;
	int pipes[2];
	aio_context_t aio_ctx;
	struct iocb *cb;
	struct iocb cbt[INFLIGTHS];
	struct io_event events[INFLIGTHS];
	unsigned int received = 0;
	int i, r;

	timeout.tv_sec = 0;
	timeout.tv_nsec = 0;
	pipe(pipes);
	memset(cbt, 0, sizeof(cbt));
	efd = eventfd(0);
	tfmfd = socket(AF_ALG, SOCK_SEQPACKET, 0);
	bind(tfmfd, (struct sockaddr *)&sa, sizeof(sa));
	setsockopt(tfmfd, SOL_ALG, ALG_SET_KEY, key, 16);
	opfd = accept(tfmfd, NULL, 0);

	msg.msg_control = cbuf;
	msg.msg_controllen = sizeof(cbuf);

	cmsg = CMSG_FIRSTHDR(&msg);
	cmsg->cmsg_level = SOL_ALG;
	cmsg->cmsg_type = ALG_SET_OP;
	cmsg->cmsg_len = CMSG_LEN(4);
	*(__u32 *)CMSG_DATA(cmsg) = ALG_OP_ENCRYPT;

	cmsg = CMSG_NXTHDR(&msg, cmsg);
	cmsg->cmsg_level = SOL_ALG;
	cmsg->cmsg_type = ALG_SET_IV;
	cmsg->cmsg_len = CMSG_LEN(20);
	iv = (void *)CMSG_DATA(cmsg);
	iv->len = 16;
	memcpy(iv->iv, oiv, 16);

	iov.iov_base = buf + IN_OFFSET;
	iov.iov_len = PKGSIZE;
	msg.msg_flags = MSG_MORE;

	aio_ctx = 0;
	r = io_setup(INFLIGTHS, &aio_ctx);
	if (r < 0) {
		perror("io_setup error");
		return -1;
	}

	for (i = 0; i < TO_SEND; i++) {
		if (zcp) {
			msg.msg_iovlen = 0;
			msg.msg_iov = NULL;

			r = sendmsg(opfd, &msg, 0);
			if (r < 0)
				printf("sendmsg returned Error: %d\n", errno);

			r = vmsplice(pipes[1], &iov, 1, SPLICE_F_GIFT);
			if (r < 0)
				printf("vmsplice returned Error: %d\n", errno);

			r = splice(pipes[0], NULL, opfd, NULL, PKGSIZE, 0);
			if (r < 0)
				printf("splice returned Error: %d\n", errno);
		} else {
			msg.msg_iovlen = 1;
			msg.msg_iov = &iov;
			r = sendmsg(opfd, &msg, PKGSIZE);
			if (r < 0)
				printf("zero cp sendmsg returned Error: %d\n", errno);
		}

		cb = &cbt[i % INFLIGTHS];
		if (cb->aio_fildes) {
			printf("req %d not processed yet???\n", i - INFLIGTHS);
			return -1;
		}
		memset(cb, '\0', sizeof(*cb));
		cb->aio_fildes = opfd;
		cb->aio_lio_opcode = IOCB_CMD_PREAD;
		cb->aio_buf = (unsigned long)buf_out + OUT_OFFSET;
		cb->aio_offset = 0;
		cb->aio_nbytes = PKGSIZE;
		cb->aio_flags = IOCB_FLAG_RESFD;
		cb->aio_resfd = efd;
		r = io_read(aio_ctx, 1, &cb);
		if (r != 1) {
			if (r < 0) {
				printf("io_read Error: %d\n", errno);
				return -1;
			} else {
				printf("Could not sumbit AIO read\n");
				return -1;
			}
		}

		FD_ZERO(&rfds);
		FD_SET(efd, &rfds);
		tv.tv_sec = 0;
		tv.tv_usec = 0;
		r = select(efd + 1, &rfds, NULL, NULL, &tv);

		if (r == -1) {
			printf("Select Error: %d\n", errno);
			return -1;
		} else if (FD_ISSET(efd, &rfds)) {
			r = io_getevents(aio_ctx, 1, INFLIGTHS, events + (received % INFLIGTHS),
					 &timeout);
			if (r > 0) {
				int y;

				for (y = 0; y < r; y++) {
					cb = (void*) events[(received + y) % INFLIGTHS].obj;
					cb->aio_fildes = 0;
					if (events[(received + y) % INFLIGTHS].res)
						printf("req %d failed\n", received + y);
				}
				received += r;
			} else if (r < 0) {
				printf("io_getevents Error: %d\n", errno);
				return -1;
			}
		}

		if (i == 0) {
			msg.msg_control = NULL;
			msg.msg_controllen = 0;
		}
	}

	while (received != TO_SEND) {
		r = io_getevents(aio_ctx, 1, TO_SEND - received,
				events + (received % INFLIGTHS), NULL);
		if (r > 0)
			received += r;
	}
	printf("All done!\n");
	close(efd);
	close(opfd);
	close(tfmfd);
	close(pipes[0]);
	close(pipes[1]);
	io_destroy(aio_ctx);
	return 0;
}

int main(int argc, char **argv)
{
	const char key[16] =
		"\x06\xa9\x21\x40\x36\xb8\xa1\x5b"
		"\x51\x2e\x03\xd5\x34\x12\x00\x06";
	char iv[16] =
		"\x3d\xaf\xba\x42\x9d\x9e\xb4\x30"
		"\xb4\x22\xda\x80\x2c\x9f\xac\x41";

	memcpy(buf, "Single block msg", 16);

	if (argc == 2) {
		printf("zero copy\n");
		crypt_kernel(key, iv, 1);
	}
	else {
		printf("copy\n");
		crypt_kernel(key, iv, 0);
	}
	return 0;
}
