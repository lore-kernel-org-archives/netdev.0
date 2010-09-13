From: <Ivan.Novick@emc.com>
Subject: Ports becoming unbindable
Date: Mon, 13 Sep 2010 12:57:29 -0400
Message-ID: <C8B3A609.3D20%ivan.novick@emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:49028 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab0IMQ6Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 12:58:25 -0400
Received: from hop04-l1d11-si02.isus.emc.com (HOP04-L1D11-SI02.isus.emc.com [10.254.111.55])
	by mexforward.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id o8DGwOAj006382
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 12:58:24 -0400
Received: from mailhub.lss.emc.com (mailhub.lss.emc.com [10.254.221.145]) by hop04-l1d11-si02.isus.emc.com (RSA Interceptor) for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 12:58:17 -0400
Received: from corpussmtp5.corp.emc.com (corpussmtp5.corp.emc.com [128.221.166.229])
	by mailhub.lss.emc.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id o8DGw4iI026725
	for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 12:58:15 -0400
Content-Language: en
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a problem where a linux machine has gotten into a state where a range
of ports are not bindable and yet it seems no application is using those
ports based on netstat and lsof output.  This has happened multiple times on
different machines but I currently have a single machine in this state that
I can do experiments on.

The port range that I cant use is: 59969-60000
The OS is: CentOS release 5.5 -- 2.6.18-194.3.1.el5

Here is python code I use to do the testing:

#############################################################
import socket
HOST = ''
for i in range(59900, 60010):
   try:
      s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      print i
      s.bind((HOST,i))

   except Exception, e:
      print str(e)
#############################################################

The error message on ports 59969-60000 is (98, 'Address already in use')

#############################################################

Using systemtap to debug the issue I got the following output for 1 call to
bind on a bad port and 1 call to bind on a good port:

     0 python(23637): -> sys_socket
    13 python(23637): <- sys_socket (3)
     0 python(23637): -> sys_bind
     6 python(23637):  -> move_addr_to_kernel
    10 python(23637):  <- move_addr_to_kernel (0)
    15 python(23637): <- sys_bind (-98)
     0 python(23637): -> sys_socket
     8 python(23637): <- sys_socket (4)
     0 python(23637): -> sys_bind
     4 python(23637):  -> move_addr_to_kernel
     7 python(23637):  <- move_addr_to_kernel (0)
    13 python(23637): <- sys_bind (0)


It shows the return code for bind is 98 in the first call (failure) and 0 in
the second call (success)

The call to move_addr_to_kernel returns 0 in both cases and from looking at
kernel sources it does not seem the system call does anything after calling
move_addr_to_kernl and before returning from bind.

Any ideas what could be the issue and or how to debug it?

Cheers,
Ivan

