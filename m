From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: inconsistent null checking in ipx_ioctl()
Date: Mon, 14 May 2012 23:56:18 +0300
Message-ID: <20120514205618.GB20836@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:47515 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757334Ab2ENU40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:56:26 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by rcsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q4EKuODg031692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 20:56:25 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q4EKuOuW016867
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 20:56:24 GMT
Received: from abhmt113.oracle.com (abhmt113.oracle.com [141.146.116.65])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q4EKuNOU016017
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 15:56:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I'm working on some new Smatch stuff and going through some warnings
in old code.

----
This is a semi-automatic email about new static checker warnings.

The patch b0d0d915d1d1: "ipx: remove the BKL" from Jan 25, 2011, 
leads to the following Smatch complaint:

net/ipx/af_ipx.c:1928 ipx_ioctl()
	 error: we previously assumed 'sk' could be null (see line 1913)

net/ipx/af_ipx.c
  1912			rc = -EINVAL;
  1913			if (sk)
                           ^^^^
Check.

  1914				rc = sock_get_timestamp(sk, argp);
  1915			break;
  1916		case SIOCGIFDSTADDR:
  1917		case SIOCSIFDSTADDR:
  1918		case SIOCGIFBRDADDR:
  1919		case SIOCSIFBRDADDR:
  1920		case SIOCGIFNETMASK:
  1921		case SIOCSIFNETMASK:
  1922			rc = -EINVAL;
  1923			break;
  1924		default:
  1925			rc = -ENOIOCTLCMD;
  1926			break;
  1927		}
  1928		release_sock(sk);
                ^^^^^^^^^^^^^^^^^
The lock and release functions dereference "sk".  Probably the check
can be removed.  The rest of the function dereferences "sk" without
checking.  A lot of this code goes back to 2.6.12.

  1929	
  1930		return rc;

regards,
dan carpenter
