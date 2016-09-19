From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] qed: Fix stack corruption on probe
Date: Mon, 19 Sep 2016 13:19:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01034F3@AcuExch.aculab.com>
References: <1474186483-30831-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: 'Yuval Mintz' <Yuval.Mintz@qlogic.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:61888 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938920AbcISNVt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 09:21:49 -0400
In-Reply-To: <1474186483-30831-1-git-send-email-Yuval.Mintz@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz
> Sent: 18 September 2016 09:15
> Commit fe56b9e6a8d95 ("qed: Add module with basic common support")
> has introduced a stack corruption during probe, where filling a
> local struct with data to be sent to management firmware is incorrectly
> filled; The data is written outside of the struct and corrupts
> the stack.
> 
> Fixes: fe56b9e6a8d95 ("qed: Add module with basic common support")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
> ---
> Hi Dave,
> 
> In case it isn't obvious at first glance, the corruption is due
> to the next line in the for-loop, which isn't changed by the patch.
> 
> Please consider applying this to `net'.
> 
> Thanks,
> Yuval
> ---
>  drivers/net/ethernet/qlogic/qed/qed_mcp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
> index a240f26..69f5b04 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
> @@ -1153,8 +1153,8 @@ qed_mcp_send_drv_version(struct qed_hwfn *p_hwfn,
>  	p_drv_version = &union_data.drv_version;
>  	p_drv_version->version = p_ver->version;
> 
> -	for (i = 0; i < MCP_DRV_VER_STR_SIZE - 1; i += 4) {
> -		val = cpu_to_be32(p_ver->name[i]);
> +	for (i = 0; i < (MCP_DRV_VER_STR_SIZE - 4) / sizeof(u32); i++) {
> +		val = cpu_to_be32(p_ver->name[i * sizeof(u32)]);
>  		*(__be32 *)&p_drv_version->name[i * sizeof(u32)] = val;
>  	}

That change fails the 'sanity' test.
It looks like it is copying a string that might by byteswapped into host order.
I'm guessing that the target p_drv_version->name[] is char [].
The cpu_to_be32() call is only correct if p_ver->name[] is 32bit.
But you are (now) indexing it with the character offset.
So the data copied cannot be right.

I also suspect it should be be32_to_cpu().

	David
