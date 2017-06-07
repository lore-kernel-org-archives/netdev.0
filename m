From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: md5: add fields to the tcp_md5sig struct to
 set a key address prefix
Date: Wed, 07 Jun 2017 05:51:24 -0700
Message-ID: <1496839884.736.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170607005414.25361-1-colona@arista.com>
         <20170607005414.25361-2-colona@arista.com>
         <1496808502.736.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170607061320.GB11691@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607061320.GB11691@ycc.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-06-07 at 08:13 +0200, Ivan Delalande wrote:
> On Tue, Jun 06, 2017 at 09:08:22PM -0700, Eric Dumazet wrote:
> > On Tue, 2017-06-06 at 17:54 -0700, Ivan Delalande wrote:
> >> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> >> index 38a2b07afdff..52ac30aa0652 100644
> >> --- a/include/uapi/linux/tcp.h
> >> +++ b/include/uapi/linux/tcp.h
> >> @@ -234,9 +234,13 @@ enum {
> >>  /* for TCP_MD5SIG socket option */
> >>  #define TCP_MD5SIG_MAXKEYLEN	80
> >>  
> >> +/* tcp_md5sig flags */
> >> +#define TCP_MD5SIG_FLAG_PREFIX		1	/* address prefix length */
> >> +
> >>  struct tcp_md5sig {
> >>  	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
> >> -	__u16	__tcpm_pad1;				/* zero */
> >> +	__u8	tcpm_flags;				/* flags */
> >> +	__u8	tcpm_prefixlen;				/* address prefix */
> >>  	__u16	tcpm_keylen;				/* key length */
> >>  	__u32	__tcpm_pad2;				/* zero */
> >>  	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
> > 
> > This will break some applications that maybe did not clear the
> > __tcpm_pad1 field ?
> > 
> > 
> > You need to find another way to maintain compatibility with old
> > applications.
> 
> All right, I thought this was acceptable after seeing a few examples of
> this in commits extending other structures in uapi, but the context and
> use were probably different for those.
> 
> We had another version of this patch which steals a bit from tcpm_keylen
> to use as a flag for this feature specifically and with the prefixlen at
> the same place as this patch. So when the flag is set we know we can
> safely interpret this part of the padding field as a prefix as all valid
> calls from older user programs should not have a key length greater than
> 80 bytes.
> 
> Would this be better? Programs compiled with the new headers could break
> on older kernels if they don't check the version, I don't know if that's
> a concern.
> 
> Or should we just add these two new fields at the end of tcp_md5sig and
> use them only if the value of optlen in the parse function called from
> setsockopt is large enough?

I believe this is the deferrable way to handle this.

But note that old kernels would not send an error back, if an
application tries the new semantic.
