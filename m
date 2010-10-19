From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 19 Oct 2010 21:44:18 +0800
Message-ID: <20101019134418.GA13514@gondor.apana.org.au>
References: <20100907084213.GA4610@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100907084213.GA4610@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 04:42:13PM +0800, Herbert Xu wrote:
> 
> This is what I am proposing for the Crypto API user-interface.
> 
> Note that this is the interface for operations.  There will be
> a separate interface (most likely netlink) for configuring crypto
> algorithms, e.g., picking a specific AES implementation as the
> system default.

OK I've gone ahead and implemented the user-space API for hashes
and ciphers.

To recap this interface is designed to allow user-space programs
to access hardware cryptographic accelerators that we have added
to the kernel.

The intended usage scenario is where a large amount of data needs
to be processed where the benefits offered by hardware acceleration
that is normally unavailable in user-space (as opposed to ones
such as the Intel AES instruction which may be used directly from
user-space) outweigh the overhead of going through the kernel.

In order to further minimise the overhead in these cases, this
interface offers the option of avoiding copying data between
user-space and the kernel where possible and appropriate.  For
ciphers this means the use of the splice(2) interface instead of
sendmsg(2)

Here is a sample hash program (note that these only illustrate
what the interface looks like and are not meant to be good examples
of coding :)

int main(void)
{
	int opfd;
	int tfmfd;
	struct sockaddr_alg sa = {
		.salg_family = AF_ALG,
		.salg_type = "hash",
		.salg_name = "sha1"
	};
	char buf[20];
	int i;

	tfmfd = socket(AF_ALG, SOCK_SEQPACKET, 0);

	bind(tfmfd, (struct sockaddr *)&sa, sizeof(sa));

	opfd = accept(tfmfd, NULL, 0);

	write(opfd, "abc", 3);
	read(opfd, buf, 20);

	for (i = 0; i < 20; i++) {
		printf("%02x", (unsigned char)buf[i]);
	}
	printf("\n");

	close(opfd);
	close(tfmfd);

	return 0;
}

And here is one for ciphers:

int main(void)
{
	int opfd;
	int tfmfd;
	struct sockaddr_alg sa = {
		.salg_family = AF_ALG,
		.salg_type = "skcipher",
		.salg_name = "cbc(aes)"
	};
	struct msghdr msg = {};
	struct cmsghdr *cmsg;
	char cbuf[CMSG_SPACE(4) + CMSG_SPACE(20)];
	char buf[16];
	struct af_alg_iv *iv;
	struct iovec iov;
	int i;

	tfmfd = socket(AF_ALG, SOCK_SEQPACKET, 0);

	bind(tfmfd, (struct sockaddr *)&sa, sizeof(sa));

	setsockopt(tfmfd, SOL_ALG, ALG_SET_KEY,
		   "\x06\xa9\x21\x40\x36\xb8\xa1\x5b"
		   "\x51\x2e\x03\xd5\x34\x12\x00\x06", 16);

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
	iv->ivlen = 16;
	memcpy(iv->iv, "\x3d\xaf\xba\x42\x9d\x9e\xb4\x30"
		       "\xb4\x22\xda\x80\x2c\x9f\xac\x41", 16);

	iov.iov_base = "Single block msg";
	iov.iov_len = 16;

	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;

	sendmsg(opfd, &msg, 0);
	read(opfd, buf, 16);

	for (i = 0; i < 16; i++) {
		printf("%02x", (unsigned char)buf[i]);
	}
	printf("\n");

	close(opfd);
	close(tfmfd);

	return 0;
}

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
