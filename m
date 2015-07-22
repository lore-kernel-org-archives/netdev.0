From: Marcelo <marcelo.leitner@gmail.com>
Subject: RE: [PATCH v2 1/2] sctp: add new getsockopt option SCTP_SOCKOPT_PEELOFF_KERNEL
Date: Wed, 22 Jul 2015 10:50:22 -0300
Message-ID: <8E017BEA-E7F7-440D-B5F8-E7AB5FF5553D@gmail.com>
References: <cover.1436891629.git.marcelo.leitner@gmail.com> <6091a8542d13f43fbe1abfa25062d28d15b15e66.1436891629.git.marcelo.leitner@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1CB695E7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:34310 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933142AbbGVNuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:50:35 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB695E7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Em 22 de julho de 2015 10:13:22 BRT, David Laight <David.Laight@ACULAB.COM> escreveu:
>From: Marcelo Ricardo Leitner
>> Sent: 14 July 2015 18:13
>> SCTP has this operation to peel off associations from a given socket
>and
>> create a new socket using this association. We currently have two
>ways
>> to use this operation:
>> - via getsockopt(), on which it will also create and return a file
>>   descriptor for this new socket
>> - via sctp_do_peeloff(), which is for kernel only
>> 
>> The caveat with using sctp_do_peeloff() directly is that it creates a
>> dependency to SCTP module, while all other operations are handled via
>> kernel_{socket,sendmsg,getsockopt...}() interface. This causes the
>> kernel to load SCTP module even when it's not really used.
>> 
>> This patch then creates a new sockopt that is to be used only by
>kernel
>> users of this protocol. This new sockopt will not allocate a file
>> descriptor but instead just return the socket pointer directly.
>> 
>> Kernel users are actually identified by if the parent socket has or
>not
>> a fd attached to it. If not, it's a kernel a user.
>> 
>> If called by an user application, it will just return -EPERM.
>> 
>> Even though it's not intended for user applications, it's listed
>under
>> uapi header. That's because hidding this wouldn't add any extra
>security
>> and to keep the sockopt list in one place, so it's easy to check
>> available numbers to use.
>> 
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>...
>> +static int sctp_getsockopt_peeloff_kernel(struct sock *sk, int len,
>> +					  char __user *optval, int __user *optlen)
>> +{
>> +	sctp_peeloff_kernel_arg_t peeloff;
>> +	struct socket *newsock;
>> +	int retval = 0;
>> +
>> +	/* We only allow this operation if parent socket also hadn't a
>> +	 * file descriptor allocated to it, mainly as a way to make sure
>> +	 * that this is really a kernel socket.
>> +	 */
>> +	if (sk->sk_socket->file)
>> +		return -EPERM;
>> +
>> +	if (len < sizeof(sctp_peeloff_kernel_arg_t))
>> +		return -EINVAL;
>> +	len = sizeof(sctp_peeloff_kernel_arg_t);
>> +	if (copy_from_user(&peeloff, optval, len))
>> +		return -EFAULT;
>
>You can't need copy_from_user() here, the buffer would surely be
>kernel.
>
>	David

Yes. It was just to avoid errors from static checkers, if any. Same for the __user in function prototype.


-- 
Sent from mobile. Please excuse my brevity.
