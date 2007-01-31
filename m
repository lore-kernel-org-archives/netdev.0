From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7909] New: malfunction of udp_get_port() in
 wildcard ports assigning
Date: Wed, 31 Jan 2007 10:32:01 -0800
Message-ID: <20070131103201.726678a7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, Konstantin.Petrov@oktetlabs.ru,
	Alexandra.Kossovsky@oktetlabs.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42240 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030531AbXAaScj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 13:32:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 31 Jan 2007 03:50:56 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7909] New: malfunction of udp_get_port() in wildcard ports assigning


http://bugzilla.kernel.org/show_bug.cgi?id=7909

           Summary: malfunction of udp_get_port() in wildcard ports
                    assigning
    Kernel Version: 2.6.19
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: Konstantin.Petrov@oktetlabs.ru
                CC: Alexandra.Kossovsky@oktetlabs.ru


Most recent kernel where this bug did *NOT* occur: 2.6.18.4
Distribution: Debian
Hardware Environment: PCs x86-64 and i686
Software Environment: 
Problem Description:

repeated binding of datagram sockets to some IP with wildcard
port fails after ~three hundred iterations with errno EADDRINUSE.
List of really assigned ports looks strangely:
...PORT[128-port-numbers-gap]PORT[128-port-numbers-gap]...

Steps to reproduce:

See code:

#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/errno.h>

int
main(int argc, char **argv)
{
    int                                 iut_s;
    int                                 retval;
    struct sockaddr_in                  servaddr,
                                        cliaddr;
    socklen_t                           namelen;
    char                                addr_buf[16];
    int                                 i;

    /* Read command line arguments */
    if (argc != 2)
    {
        printf("\nuse pco_iut <local IP>\n");
        return -1;
    }

    memset(&servaddr, 0, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET, argv[1], &servaddr.sin_addr);
    servaddr.sin_port = 0;

    for (i = 0; i < 1024; i++)
    {
        if ( (iut_s = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
        {
            printf("\nFailed to create socket No %d error %d\n", i + 1,
                    errno);
            return -1;
        }

        if (bind(iut_s,(struct sockaddr *) &servaddr, sizeof(servaddr)) != 0)
        {
            printf("\nFailed to bind socket No %d error %d\n", i + 1,
                    errno);
            return -1;
        }

        namelen = sizeof(cliaddr);
        if (getsockname(iut_s, (struct sockaddr *)&cliaddr, &namelen) != 0)
        {
            printf("\ngetsockname() error errno %d\n", errno);
            return -1;
        }
        else
        {
            inet_ntop(AF_INET, &cliaddr.sin_addr,
                        addr_buf, 16);
            printf("\nBound to %s:%d\n",
                    addr_buf,
                    ntohs(cliaddr.sin_port));
        }
    }

    return 0;
}


The reason of this issue is IMHO in udp_get_port() function
which was added in 2.6.19 version to replace udp_v4_get_port()
in older versions.
 
In ugp_get_port() we see the strange piece of code

.................................................................
                        size = 0;
                        sk_for_each(sk2, node, head)
                                if (++size < best_size_so_far) {
                                        best_size_so_far = size;
                                        best = result;
                                }
                }
                result = best;
                for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result +=
UDP_HTABLE_SIZE) {
..........................................................................

which means that sk_for_each(...) iteration is repeated only once.

No such problem in older kernels where the similar
piece of code in udp_v4_get_port() looks like

..........................................................................
                        size = 0;
                        sk_for_each(sk2, node, list)
                                if (++size >= best_size_so_far)
                                        goto next;
                        best_size_so_far = size;
                        best = result;
                next:;
                }
                result = best;
                for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result +=
UDP_HTABLE_SIZE) {

..........................................................................

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
