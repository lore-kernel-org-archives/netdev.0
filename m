From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [Security] [SECURITY] DECnet: need to validate user data and
 access data?
Date: Tue, 22 Mar 2011 09:13:50 +0000
Message-ID: <1300785230.2558.6.camel@dolmen>
References: <1300750901.1813.15.camel@dan>
	 <AANLkTinbj295sZvXrQm6uhH9+DbAbY1AZU7Eo5_dC6HP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, davem@davemloft.net,
	netdev@vger.kernel.org, security@kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: Eugene Teo <eugeneteo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab1CVJLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 05:11:51 -0400
In-Reply-To: <AANLkTinbj295sZvXrQm6uhH9+DbAbY1AZU7Eo5_dC6HP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 2011-03-22 at 15:42 +0800, Eugene Teo wrote:
> Cc'ed the decnet list. Looks like it's still active even though the
> status is orphan.
> 
Well, kind of active :-) I don't think there is a lot of development
going on despite davem's recent changes to the routing code.

These functions are used in relation to conninit messages which, on the
incoming side are checked in dn_nsp_in.c:dn_find_listener() via the
calls to dn_check_idf() so that we should never queue an incorrectly
formatted message to the socket. The intent was that all messages should
be checked as early as possible on entry to the code so that we can then
rely on their content later on without needing to check again.

I hope that answers your question, but let me know if you need anything
else,

Steve.

> On Tue, Mar 22, 2011 at 7:41 AM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > In net/decnet/af_decnet.c, in the dn_access_copy() and dn_user_copy()
> > functions, which are called from dn_connect(), length values are
> > retrieved from incoming skb data and used as size values to copy
> > functions:
> >
> > static void dn_access_copy(struct sk_buff *skb, struct accessdata_dn *acc)
> > {
> >        unsigned char *ptr = skb->data;
> >
> >        acc->acc_userl = *ptr++;
> >        memcpy(&acc->acc_user, ptr, acc->acc_userl);
> >        ptr += acc->acc_userl;
> >
> >        acc->acc_passl = *ptr++;
> >        memcpy(&acc->acc_pass, ptr, acc->acc_passl);
> >        ptr += acc->acc_passl;
> >
> >        acc->acc_accl = *ptr++;
> >        memcpy(&acc->acc_acc, ptr, acc->acc_accl);
> >
> >        skb_pull(skb, acc->acc_accl + acc->acc_passl + acc->acc_userl + 3);
> >
> > }
> >
> > static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
> > {
> >        unsigned char *ptr = skb->data;
> >        u16 len = *ptr++; /* yes, it's 8bit on the wire */
> >
> >        BUG_ON(len > 16); /* we've checked the contents earlier */
> >        opt->opt_optl   = cpu_to_le16(len);
> >        opt->opt_status = 0;
> >        memcpy(opt->opt_data, ptr, len);
> >        skb_pull(skb, len + 1);
> > }
> >
> >
> > Despite the BUG_ON and comment suggesting these lengths have been
> > validated, I don't think this is actually the case - it looks like these
> > fields are validated for outbound data, but I see no validation for
> > inbound data (unless I'm mistaken, which is entirely possible).  If this
> > is the case, this can allow remote attackers to cause controllable heap
> > corruption.  I'd appreciate it if someone who knows this protocol better
> > than I do took a look at this and implemented appropriate error handling
> > if it needs it.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


