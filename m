From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 2/2] checkpatch: suggest using eth_zero_addr() and
 eth_broadcast_addr()
Date: Sun, 19 Apr 2015 18:13:04 -0700
Message-ID: <1429492384.27863.13.camel@perches.com>
References: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>
	 <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-04-20 at 00:16 +0200, Mateusz Kulikowski wrote:
> Suggest using eth_zero_addr() or eth_broadcast_addr() instead of memset().

Hi again Mateusz

> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
[]
> @@ -5042,6 +5042,22 @@ sub process {
>  			     "Prefer ether_addr_equal() or ether_addr_equal_unaligned() over memcmp()\n" . $herecurr)
>  		}
>  
> +# check for memset(foo, 0x0, ETH_ALEN) that could be eth_zero_addr
> +# check for memset(foo, 0xFF, ETH_ALEN) that could be eth_broadcast_addr
> +		if ($^V && $^V ge 5.10.0 &&
> +		    $line =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {

Because you are working with $line and not $stat,
the last /s isn't useful here.

$line is always a single line.

> +			my $ms_val = $7;
> +
> +			if ($ms_val =~ /^(0x|)0+$/i) {

It's trivially faster to use (?:0x|) so the 0x is not captured.

> +				WARN("PREFER_ETH_ZERO_ADDR",
> +				     "Prefer eth_zero_addr over memset()\n" . $herecurr);

And these could be:
				if (WARN(...) &&
				    $fix) {
					$fixed[$fixlinenr] = s/\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*,\s*ETH_ALEN\s*\)/eth_zero_addr($1)/;
				}
			}
		
> +			} elsif ($ms_val =~ /^(?:0xff|255)$/i) {
> +				WARN("PREFER_ETH_BROADCAST_ADDR",
> +				     "Prefer eth_broadcast_addr() over memset()\n" . $herecurr);

				if (WARN(...) &&
				    $fix) {
					$fixed[$fixlinenr] = s/\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*,\s*ETH_ALEN\s*\)/eth_broadcast_addr($1)/;
				}

cheers, Joe
