From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [Security] [SECURITY] DECnet: need to validate user data and
 access data?
Date: Tue, 22 Mar 2011 07:01:37 -0400
Message-ID: <1300791697.1813.21.camel@dan>
References: <1300750901.1813.15.camel@dan>
	 <AANLkTinbj295sZvXrQm6uhH9+DbAbY1AZU7Eo5_dC6HP@mail.gmail.com>
	 <1300785230.2558.6.camel@dolmen>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Teo <eugeneteo@kernel.org>, davem@davemloft.net,
	netdev@vger.kernel.org, security@kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:65228 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab1CVLBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 07:01:44 -0400
In-Reply-To: <1300785230.2558.6.camel@dolmen>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-22 at 09:13 +0000, Steven Whitehouse wrote:
> Hi,
> 
> On Tue, 2011-03-22 at 15:42 +0800, Eugene Teo wrote:
> > Cc'ed the decnet list. Looks like it's still active even though the
> > status is orphan.
> > 
> Well, kind of active :-) I don't think there is a lot of development
> going on despite davem's recent changes to the routing code.
> 
> These functions are used in relation to conninit messages which, on the
> incoming side are checked in dn_nsp_in.c:dn_find_listener() via the
> calls to dn_check_idf() so that we should never queue an incorrectly
> formatted message to the socket. The intent was that all messages should
> be checked as early as possible on entry to the code so that we can then
> rely on their content later on without needing to check again.
> 
> I hope that answers your question, but let me know if you need anything
> else,

Thanks very much, that does clear it up.  I must have missed it because
I was expecting it to use the array size macro (DN_MAXACCL) rather than
a hard-coded value.  Glad it's a non-issue.

-Dan

> Steve.
> 
> > On Tue, Mar 22, 2011 at 7:41 AM, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > > In net/decnet/af_decnet.c, in the dn_access_copy() and dn_user_copy()
> > > functions, which are called from dn_connect(), length values are
> > > retrieved from incoming skb data and used as size values to copy
> > > functions:
> > >
> > > static void dn_access_copy(struct sk_buff *skb, struct accessdata_dn *acc)
> > > {
> > >        unsigned char *ptr = skb->data;
> > >
> > >        acc->acc_userl = *ptr++;
> > >        memcpy(&acc->acc_user, ptr, acc->acc_userl);
> > >        ptr += acc->acc_userl;
> > >
> > >        acc->acc_passl = *ptr++;
> > >        memcpy(&acc->acc_pass, ptr, acc->acc_passl);
> > >        ptr += acc->acc_passl;
> > >
> > >        acc->acc_accl = *ptr++;
> > >        memcpy(&acc->acc_acc, ptr, acc->acc_accl);
> > >
> > >        skb_pull(skb, acc->acc_accl + acc->acc_passl + acc->acc_userl + 3);
> > >
> > > }
> > >
> > > static void dn_user_copy(struct sk_buff *skb, struct optdata_dn *opt)
> > > {
> > >        unsigned char *ptr = skb->data;
> > >        u16 len = *ptr++; /* yes, it's 8bit on the wire */
> > >
> > >        BUG_ON(len > 16); /* we've checked the contents earlier */
> > >        opt->opt_optl   = cpu_to_le16(len);
> > >        opt->opt_status = 0;
> > >        memcpy(opt->opt_data, ptr, len);
> > >        skb_pull(skb, len + 1);
> > > }
> > >
> > >
> > > Despite the BUG_ON and comment suggesting these lengths have been
> > > validated, I don't think this is actually the case - it looks like these
> > > fields are validated for outbound data, but I see no validation for
> > > inbound data (unless I'm mistaken, which is entirely possible).  If this
> > > is the case, this can allow remote attackers to cause controllable heap
> > > corruption.  I'd appreciate it if someone who knows this protocol better
> > > than I do took a look at this and implemented appropriate error handling
> > > if it needs it.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


