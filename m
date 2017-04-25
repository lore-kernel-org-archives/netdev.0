From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 1/4] netlink: make extended ACK setting NULL-friendly
Date: Tue, 25 Apr 2017 11:12:11 +0200
Message-ID: <58FF12EB.7090700@iogearbox.net>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com> <20170425080644.122536-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33634 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943761AbdDYJMP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 05:12:15 -0400
In-Reply-To: <20170425080644.122536-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2017 10:06 AM, Jakub Kicinski wrote:
> As we propagate extended ack reporting throughout various paths in
> the kernel it may happen that the same function is called with the
> extended ack parameter passed as NULL.  Make the NL_SET_ERR_MSG()
> macro simply print the message to the logs if that happens.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>   include/linux/netlink.h | 12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index 8d2a8924705c..b59cfbf2e2c7 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -86,10 +86,14 @@ struct netlink_ext_ack {
>    * Currently string formatting is not supported (due
>    * to the lack of an output buffer.)
>    */
> -#define NL_SET_ERR_MSG(extack, msg) do {	\
> -	static const char _msg[] = (msg);	\
> -						\
> -	(extack)->_msg = _msg;			\
> +#define NL_SET_ERR_MSG(extack, msg) do {		\
> +	struct netlink_ext_ack *_extack = (extack);	\
> +	static const char _msg[] = (msg);		\
> +							\
> +	if (_extack)					\
> +		_extack->_msg = _msg;			\
> +	else						\
> +		pr_info("%s\n", _msg);			\
>   } while (0)
>
>   extern void netlink_kernel_release(struct sock *sk);

Probably makes sense to have a NL_MOD_SET_ERR_MSG(), which
then also prepends a KBUILD_MODNAME ": " string to the
message (similar to pr_*()), so that it's easier to identify
whether the error came from a specific driver or rather
common core code?
