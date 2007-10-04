From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: [PATCH] net: fix kernel_accept() error path
Date: Thu, 04 Oct 2007 18:12:53 -0400
Message-ID: <47056565.50803@cybernetics.com>
References: <47054AF5.4050409@cybernetics.com> <Xine.LNX.4.64.0710041456300.13076@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host06.cybernetics.com ([206.246.200.22]:4839 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1758138AbXJDWMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 18:12:49 -0400
In-Reply-To: <Xine.LNX.4.64.0710041456300.13076@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Thu, 4 Oct 2007, Tony Battersby wrote:
>
>   
>> If accept() returns an error, kernel_accept() releases the new socket
>> but passes a pointer to the released socket back to the caller.  Make it
>> pass back NULL instead.
>>
>> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
>> ---
>> --- linux-2.6.23-rc9/net/socket.c.bak	2007-10-04 15:21:17.000000000 -0400
>> +++ linux-2.6.23-rc9/net/socket.c	2007-10-04 15:21:22.000000000 -0400
>> @@ -2230,6 +2230,7 @@ int kernel_accept(struct socket *sock, s
>>  	err = sock->ops->accept(sock, *newsock, flags);
>>  	if (err < 0) {
>>  		sock_release(*newsock);
>> +		*newsock = NULL;
>>  		goto done;
>>  	}
>>  
>>     
>
> If you get an error back from kernel_accept, you should not be trying to 
> use newsock.
>
>   

Here is an example of what I would consider "reasonable code" that would
fail:

int example()
{
    struct socket *conn_socket = NULL;
    int err;

    ...

    if ((err = kernel_accept(sock, &conn_socket, 0)) < 0)
        goto out_cleanup;

    [do whatever with conn_socket]

 out_cleanup:

    if (conn_socket != NULL)
        sock_release(&conn_socket);

    return err;
}

Without the patch, the double sock_release() will cause a BUG().

Also compare to sock_create_lite(), which sets *res to NULL on error.

Tony

