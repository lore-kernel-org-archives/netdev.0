From: David Ward <david.ward@ll.mit.edu>
Subject: Re: [RFC] iproute2: gracefully exit from rtnl_listen()
Date: Tue, 01 Sep 2009 22:27:30 -0400
Message-ID: <4A9DD812.8010202@ll.mit.edu>
References: <1251841286-32463-1-git-send-email-david.ward@ll.mit.edu> <20090901155955.7448c1d6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deliverator10.gatech.edu ([130.207.160.100]:55615 "EHLO
	deliverator10.gatech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575AbZIBC7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 22:59:48 -0400
Received: from deliverator3.ecc.gatech.edu (deliverator3.ecc.gatech.edu [130.207.185.173])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by deliverator10.gatech.edu (Postfix) with ESMTP id 2BD7D4CFD5
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 22:28:41 -0400 (EDT)
In-Reply-To: <20090901155955.7448c1d6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2009 06:59 PM, Stephen Hemminger wrote:
>
> On Tue,  1 Sep 2009 17:41:26 -0400
> David Ward <david.ward@ll.mit.edu> wrote:
>>
>> There should be some mechanism for stopping rtnl_listen() and
>> continuing program execution.
>
> Good idea, but why not just change the while(1) loop?

Stephen, thanks for your response. I agree that checking a condition on 
the while loop, as you showed, can be used to exit the loop cleanly.

Here are my concerns though:

    * rtnl_listen() is the function that I believe needs to be fixed.
      It is what allows applications to passively observe messages sent
      to the rtnetlink multicast groups -- messages which are not
      prompted by any request from the application, where there is no
      defined "end" to the sequence of messages being received. This
      function currently has no condition in the loop where it will stop
      trying to receive messages and exit cleanly.

      rtnl_dump_filter(), which your patch modifies, appears to be for
      processing the response to an rtnetlink dump request from the
      application. It is at least able to exit cleanly when it sees the
      NLMSG_DONE message at the end of the kernel's response.

      However, I think that any changes that are made to rtnl_listen()
      which allow it to exit gracefully could potentially be applied to
      the loops in rtnl_dump_filter() and rtnl_talk() as well.

    * With your patch, rtnl_dump_filter() returns -1 after the rtnetlink
      socket is closed. This indicates than an error has occurred.
      However, because trying to exit the loop by closing the socket is
      intentional, the function should be able to return 0.

      But could there be other cases where the rtnetlink socket is closed
      unintentionally, and -1 actually needs to be returned?

    * Is it really necessary to close the rtnetlink socket in order to
      break out of rtnl_listen()? What if the user wants to continue
      using the socket -- should the socket have to be closed to exit
      from rtnl_listen(), and then reopened? Is there a better way to
      notify the loop to exit instead?

    * Furthermore, should you have to rely on a signal like SIGINT to be
      received by the application in order to check for the condition
      under which to break out of the loop? Shouldn't it be possible to
      break out of the loop without a signal? But recvmsg() is blocking.


Again, I am raising these questions because I'm not sure what a 
"correct" solution to breaking out of rtnl_listen() would look like.

Thanks,

David
