From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] Add the command to show the time
 stamping capabilities.
Date: Mon, 2 Apr 2012 20:25:58 +0100
Message-ID: <1333394758.5356.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333293808-7729-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>, Martin,
	Jacob Keller <jacob.e.keller@intel.com>, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1333293808-7729-1-git-send-email-richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-01 at 17:23 +0200, Richard Cochran wrote:
[...]
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -38,6 +38,7 @@
>  #include <netinet/in.h>
>  #include <arpa/inet.h>
>  
> +#include <linux/net_tstamp.h>

ethtool is meant to be compilable on quite old systems, so we can't
unconditionally include this header.  Perhaps we should carry a copy of
it, like ethtool-copy.h?

>  #include <linux/sockios.h>
>  
>  #ifndef MAX_ADDR_LEN
> @@ -1115,6 +1116,91 @@ static int dump_rxfhash(int fhash, u64 val)
>  	return 0;
>  }
>  
> +static int dump_tsinfo(const struct ethtool_ts_info *info)
> +{
> +	if (info->so_timestamping & SOF_TIMESTAMPING_TX_HARDWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_TX_HARDWARE\n");
> +
> +	if (info->so_timestamping & SOF_TIMESTAMPING_TX_SOFTWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_TX_SOFTWARE\n");
> +
> +	if (info->so_timestamping & SOF_TIMESTAMPING_RX_HARDWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_RX_HARDWARE\n");
> +
> +	if (info->so_timestamping & SOF_TIMESTAMPING_RX_SOFTWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_RX_SOFTWARE\n");
> +
> +	if (info->so_timestamping & SOF_TIMESTAMPING_SOFTWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_SOFTWARE\n");
> +
> +	if (info->so_timestamping & SOF_TIMESTAMPING_SYS_HARDWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_SYS_HARDWARE\n");
> +
> +	if (info->so_timestamping & SOF_TIMESTAMPING_RAW_HARDWARE)
> +		fprintf(stdout, "SOF_TIMESTAMPING_RAW_HARDWARE\n");

I would prefer for these to be shown as more human-understandable
capabilities.  Include the flag name in parentheses if you like.

> +	if (info->phc_index < 0)
> +		fprintf(stdout, "No PTP Hardware Clock\n");
> +	else
> +		fprintf(stdout, "PTP Hardware Clock %d\n", info->phc_index);

ethtool generally reports settings as 'name: value' so how about
"PTP Hardware Clock: none" and "PTP Hardware Clock: %d"?

> +	if (info->tx_types & (1 << HWTSTAMP_TX_OFF))
> +		fprintf(stdout, "HWTSTAMP_TX_OFF\n");
> +
> +	if (info->tx_types & (1 << HWTSTAMP_TX_ON))
> +		fprintf(stdout, "HWTSTAMP_TX_ON\n");
> +
> +	if (info->tx_types & (1 << HWTSTAMP_TX_ONESTEP_SYNC))
> +		fprintf(stdout, "HWTSTAMP_TX_ONESTEP_SYNC\n");

If there is no hardware timestamping available then shouldn't we see
HWTSTAMP_TX_OFF reported here?  But that's going to be the case.  Not
sure whether the kernel or the ethtool utility should deal with that,
but don't assume the ethtool utility is the only consumer.

> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_NONE))
> +		fprintf(stdout, "HWTSTAMP_FILTER_NONE\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_ALL))
> +		fprintf(stdout, "HWTSTAMP_FILTER_ALL\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_SOME))
> +		fprintf(stdout, "HWTSTAMP_FILTER_SOME\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V1_L4_EVENT\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V1_L4_SYNC\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L4_EVENT\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L4_SYNC\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L2_EVENT\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L2_SYNC\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_EVENT))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_EVENT\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_SYNC))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_SYNC\n");
> +
> +	if (info->rx_filters & (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ))
> +		fprintf(stdout, "HWTSTAMP_FILTER_PTP_V2_DELAY_REQ\n");

Similarly, shouldn't we see HWTSTAMP_FILTER_NONE reported here?

I think each of the capability lists should have its own heading.
Combining all of my suggestions, I think you should see for example:

Capabilities:
	receive-stack (SOF_TIMESTAMPING_RX_SOFTWARE)
	transmit-stack (SOF_TIMESTAMPING_SOFTWARE)
	transmit-driver (SOF_TIMESTAMPING_TX_SOFTWARE)
PTP Hardware Clock: none
Hardware Transmit Modes:
	off (HWTSTAMP_TX_OFF)
Hardware Receive Filter Modes:
	none (HWTSTAMP_FILTER_NONE)

or:

Capabilities:
	software-transmit (SOF_TIMESTAMPING_TX_SOFTWARE)
	software-receive (SOF_TIMESTAMPING_RX_SOFTWARE)
	software-system-clock (SOF_TIMESTAMPING_SOFTWARE)
	hardware-transmit (SOF_TIMESTAMPING_TX_HARDWARE)
	hardware-receive (SOF_TIMESTAMPING_RX_HARDWARE)
	hardware-system-clock (SOF_TIMESTAMPING_SYS_HARDWARE)
PTP Hardware Clock: 1
Hardware Transmit Modes: 
	off (HWTSTAMP_TX_OFF)
	on (HWTSTAMP_TX_ON)
	one-step (HWTSTAMP_TX_ONESTEP_SYNC)
Hardware Receive Filter Modes:
	none (HWTSTAMP_FILTER_NONE)
	ptpv2-l4-event (HWTSTAMP_FILTER_PTP_V2_L4_EVENT)
	ptpv2-l4-sync (HWTSTAMP_FILTER_PTP_V2_L4_SYNC)

(Maybe you can think of better names.)

> +	return 0;
> +}
> +
>  static struct ethtool_gstrings *
>  get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
>  	      ptrdiff_t drvinfo_offset)
> @@ -3077,6 +3163,23 @@ static int do_sprivflags(struct cmd_context *ctx)
>  	return 0;
>  }
>  
> +static int do_tsinfo(struct cmd_context *ctx)
> +{
> +	struct ethtool_ts_info info;
> +
> +	if (ctx->argc != 0)
> +		exit_bad_args();
> +
> +	fprintf(stdout, "Time stamping parameters for %s:\n", ctx->devname);
> +	info.cmd = ETHTOOL_GET_TS_INFO;
> +	if (send_ioctl(ctx, &info)) {
> +		perror("Cannot get device time stamping settings");
> +		return -1;
> +	}
> +	dump_tsinfo(&info);
> +	return 0;
> +}
> +
>  int send_ioctl(struct cmd_context *ctx, void *cmd)
>  {
>  #ifndef TEST_ETHTOOL
> @@ -3206,6 +3309,7 @@ static const struct option {
>  	  "			[ action %d ]\n"
>  	  "			[ loc %d]] |\n"
>  	  "		delete %d\n" },
> +	{ "-T|--timestamping", 1, do_tsinfo, "Show time stamping options" },

Surely 'capabilities'.

You need to add this new option to the manual page and unit tests
(test-cmdline.c) as well.

Ben.

>  	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
>  	  "Show Rx flow hash indirection" },
>  	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
