From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip: add MACsec support
Date: Mon, 7 Mar 2016 11:48:42 -0800
Message-ID: <20160307114842.4314d50b@xeon-e3>
References: <cover.1456937772.git.sd@queasysnail.net>
	<e448dc09765ed22e9bd8353acbe85e7f692aa2f6.1457369326.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33476 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbcCGTsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:48:30 -0500
Received: by mail-pa0-f46.google.com with SMTP id fl4so83645767pad.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 11:48:29 -0800 (PST)
In-Reply-To: <e448dc09765ed22e9bd8353acbe85e7f692aa2f6.1457369326.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +static int one_of(const char *msg, const char *realval, const char **list,
> +		  size_t len, int *index)
> +{
> +	int i;
> +
> +	for (i = 0; i < len; i++) {
> +		if (matches(realval, list[i]) == 0) {
> +			*index = i;
> +			return 0;
> +		}
> +	}
> +
> +	fprintf(stderr, "Error: argument of \"%s\" must be one of ", msg);
> +	for (i = 0; i < len; i++)
> +		fprintf(stderr, "\"%s\", ", list[i]);
> +	fprintf(stderr, "not \"%s\"\n", realval);
> +	return -1;
> +}
> +
> +static int get_an(__u8 *val, const char *arg)
> +{
> +	int ret = get_u8(val, arg, 0);
> +
> +	if (ret)
> +		return ret;
> +
> +	if (*val > 3)
> +		return -1;
> +
> +	return 0;
> +}
> +
> +static int get_sci(__u64 *sci, const char *arg)
> +{
> +	return get_u64(sci, arg, 16);
> +}
> +
> +static int get_port(__be16 *port, const char *arg)
> +{
> +	__u16 p;
> +	int ret = get_u16(&p, arg, 10);
> +
> +	if (ret)
> +		return ret;
> +
> +	*port = htons(p);
> +	return 0;
> +}

Some of these should probably go into lib

> +static int from_hex(char c)
> +{
> +	if (c >= '0' && c <= '9')
> +		return c - '0';
> +	if (c >= 'a' && c <= 'f')
> +		return c - 'a' + 10;
> +	if (c >= 'A' && c <= 'F')
> +		return c - 'A' + 10;
> +
> +	return -1;
> +}

There already several copies of similar code (ipl2tp, ipmaddr, ipx)
for basically the same code.

...
> +	print_flag(stdout, attrs, "sc", MACSEC_ATTR_SC_ACTIVE);
> +	print_flag(stdout, attrs, "sa", MACSEC_ATTR_SA_ACTIVE);
> +	print_flag(stdout, attrs, "encrypt", MACSEC_ATTR_ENCRYPT);
> +	print_flag(stdout, attrs, "send_sci", MACSEC_ATTR_INC_SCI);
> +	print_flag(stdout, attrs, "end_station", MACSEC_ATTR_ES);
> +	print_flag(stdout, attrs, "scb", MACSEC_ATTR_SCB);
> +
> +	print_flag(stdout, attrs, "replayprotect", MACSEC_ATTR_REPLAY);
> +	if (attrs[MACSEC_ATTR_WINDOW]) {
> +		printf("window %d ",
> +		       rta_getattr_u32(attrs[MACSEC_ATTR_WINDOW]));
> +	}
> +
> +	if (attrs[MACSEC_ATTR_CIPHER_SUITE] && attrs[MACSEC_ATTR_ICV_LEN]) {
> +		printf("\n");
> +		print_cipher_suite(prefix,
> +			rta_getattr_u64(attrs[MACSEC_ATTR_CIPHER_SUITE]),
> +			rta_getattr_u8(attrs[MACSEC_ATTR_ICV_LEN]));
> +	}
> +
> +}

It is unwritten rule of ip commands that the print and set commands should
be invertable. I.e if you are going to print an attribute the format should
be the same as the argument passed in.
