From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv4] ethtool: Added FW dump support
Date: Wed, 01 Jun 2011 22:35:09 +0100
Message-ID: <1306964109.2758.30.camel@bwh-desktop>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48113 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756382Ab1FAVfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 17:35:11 -0400
In-Reply-To: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 15:48 -0700, Anirban Chakraborty wrote:
> Added support to take FW dump via ethtool.
> 
> Changes since v3:
> Updated documentation for ethtool_dump data structure

You don't need to include the changes to ethtool-copy.h in the same
patch.  I've just updated it from today's net-next-2.6.

> Changes from v2:
> Folded get dump flag and data into one option
> Added man page support

Unfortunately the man page changes no longer apply (and they didn't when
you sent this, either).

[...]
> diff --git a/ethtool.8.in b/ethtool.8.in
> index 9f484fb..3042e7c 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -301,6 +301,17 @@ ethtool \- query or control network driver and hardware settings
>  .RB [ user\-def\-mask
>  .IR mask ]]
>  .RI action \ N
> +.br
> +.HP
> +.B ethtool \-w|\-\-get\-dump
> +.I ethX
> +.RB [ data
> +.IR filename ]
> +.HP
> +.B ethtool\ \-W|\-\-set\-dump
> +.I ethX
> +.BI \ N
> +.HP

.HP starts a new paragraph; don't add an empty paragraph at the end.

>  .
>  .\" Adjust lines (i.e. full justification) and hyphenate.
>  .ad
> @@ -711,6 +722,18 @@ lB	l.
>  -1	Drop the matched flow
>  0 or higher	Rx queue to route the flow
>  .TE
> +.TP
> +.B \-w \-\-get\-dump
> +Retrieves and prints firmware dump for the specified network device.
> +By default, it prints out the dump flag, version and length of the dump data.
> +When
> +.I data
> +is indicated, then ethtool fetches the dump data and directs it to a
> +.I file.
> +.TP
> +.B \-W \-\-set\-dump
> +Sets the dump flag for the device.
> +.TP

The same is true for .TP.

[...]
> +static void do_writefwdump(struct ethtool_dump *dump)
> +{
> +	FILE *f;
> +	size_t bytes;
> +
> +	f = fopen(dump_file, "wb+");
> +
> +	if (!f) {
> +		fprintf(stderr, "Can't open file %s: %s\n",
> +			dump_file, strerror(errno));
> +		return;
> +	}
> +	bytes = fwrite(dump->data, 1, dump->len, f);

You must report an error if bytes != dump->len. 

> +	if (fclose(f))
> +		fprintf(stderr, "Can't close file %s: %s\n",
> +			dump_file, strerror(errno));
> +}

These errors *must* be reported through the program's exit code, not
just on stderr.

> +static int do_getfwdump(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +	struct ethtool_dump edata;
> +	struct ethtool_dump *data;
> +
> +	edata.cmd = ETHTOOL_GET_DUMP_FLAG;
> +
> +	ifr->ifr_data = (caddr_t) &edata;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0) {
> +		perror("Can not get dump level");
> +		return 74;
> +	}
> +	if (dump_flag != ETHTOOL_GET_DUMP_DATA) {
> +		fprintf(stdout, "flag: %u, version: %u, length: %u\n",
> +			edata.flag, edata.version, edata.len);
> +		return 0;
> +	}
> +	data = calloc(1, offsetof(struct ethtool_dump, data) + edata.len);
> +	if (!data) {
> +		perror("Can not allocate enough memory");
> +		return 0;
> +	}
> +	data->cmd = ETHTOOL_GET_DUMP_DATA;
> +	data->len = edata.len;
> +	ifr->ifr_data = (caddr_t) data;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0) {
> +		perror("Can not get dump data\n");
> +		goto free;
> +	}
> +	do_writefwdump(data);
> +free:
> +	free(data);
> +	return 0;
> +}
> +
> +static int do_setfwdump(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +	struct ethtool_dump dump;
> +
> +	dump.cmd = ETHTOOL_SET_DUMP;
> +	dump.flag = dump_flag;
> +	ifr->ifr_data = (caddr_t)&dump;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0) {
> +		perror("Can not set dump level");
> +		return 74;
> +	}
> +	return 0;
> +}
> +
>  static int send_ioctl(int fd, struct ifreq *ifr)
>  {
>  	return ioctl(fd, SIOCETHTOOL, ifr);

The eturn value must be 0 on success, 1 on failure.  Some other
functions return different values for specific failure points, but new
features should not do that.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

