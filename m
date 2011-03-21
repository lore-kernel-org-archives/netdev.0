From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [SECURITY] DECnet: need to validate user data and access data?
Date: Mon, 21 Mar 2011 19:41:41 -0400
Message-ID: <1300750901.1813.15.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: security@kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:50928 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093Ab1CUXls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 19:41:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In net/decnet/af_decnet.c, in the dn_access_copy() and dn_user_copy()
functions, which are called from dn_connect(), length values are
retrieved from incoming skb data and used as size values to copy
functions:

static void dn_access_copy(struct sk_buff *skb, struct accessdata_dn *acc)
{
        unsigned char *ptr = skb->data;

        acc->acc_userl = *ptr++;
        memcpy(&acc->acc_user, ptr, acc->acc_userl);
        ptr += acc->acc_userl;

        acc->acc_passl = *ptr++;
        memcpy(&acc->acc_pass, ptr, acc->acc_passl);
        ptr += acc->acc_passl;

        acc->acc_accl = *ptr++;
        memcpy(&acc->acc_acc, ptr, acc->acc_accl);

        skb_pull(skb, acc->acc_accl + acc->acc_passl + acc->acc_userl + 3);

}

static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
{
        unsigned char *ptr = skb->data;
        u16 len = *ptr++; /* yes, it's 8bit on the wire */

        BUG_ON(len > 16); /* we've checked the contents earlier */
        opt->opt_optl   = cpu_to_le16(len);
        opt->opt_status = 0;
        memcpy(opt->opt_data, ptr, len);
        skb_pull(skb, len + 1);
}


Despite the BUG_ON and comment suggesting these lengths have been
validated, I don't think this is actually the case - it looks like these
fields are validated for outbound data, but I see no validation for
inbound data (unless I'm mistaken, which is entirely possible).  If this
is the case, this can allow remote attackers to cause controllable heap
corruption.  I'd appreciate it if someone who knows this protocol better
than I do took a look at this and implemented appropriate error handling
if it needs it.

Thanks,
Dan

