From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 21:24:18 +0100
Message-ID: <39CEA2B6BDF36C1FA4B1EF64@nimrod.local>
References: <4DC83471.7030701@candelatech.com>
 <06627C760FB049F1A9321BC6@Ximines.local> <4DC83A57.40405@candelatech.com>
 <D8B72070C6338973B87C9EFA@Ximines.local> <4DC843AF.6050607@candelatech.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alex Bligh <alex@alex.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:42750 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754366Ab1EIUYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 16:24:21 -0400
In-Reply-To: <4DC843AF.6050607@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

--On 9 May 2011 12:42:39 -0700 Ben Greear <greearb@candelatech.com> wrote:

> I use HZ of 1000, btw.
>
> I killed udev, haldaemon..seemed to be just my stuff running.
>
> I don't see any 'ifup' running with these things dead...
>
> If you want to post your script, I can run it on my
> machine...

See below - run (on ubuntu) by
  service udev stop
  unshare -n bash
  ./ifseq -n 500

The unshare seems sufficient to stop any remaining udev listeners getting
wind of interface creation/deletion.

-- 
Alex Bligh


#!/bin/bash

# Usage:
#   ifaceseq [options]
#
# Options:
#   -n NUM : use NUM interfaces
#   -t TYPE : use TYPE of interfaces (supported: veth, vlan)

numifs=10
itype=veth

while getopts n:t: flag; do
    case ${flag} in
	n) numifs=${OPTARG} ;;
	t) itype=${OPTARG} ;;
    esac
done

shift $((OPTIND-1))

createifs ()
{
    echo `date` creating $numifs interfaces
    case ${itype} in
	vlan)
	    for i in `seq 1 $numifs` ; do
		ip link add link eth0 name vlan${i} type vlan id ${i}
	    done
	    ;;
	*)
	    for i in `seq 1 $numifs` ; do
		ip link add testa${i} type veth peer name testb${i}
	    done
    esac
    echo `date` done
}

deleteifs ()
{
    echo `date` deleting $numifs interfaces
    case ${itype} in
	vlan)
	    for i in `seq 1 $numifs` ; do
		ip link delete dev vlan${i}
	    done
	    ;;
	*)
	    for i in `seq 1 $numifs` ; do
		ip link delete testa${i}
	    done
    esac
    echo `date` done
}

time createifs;
time deleteifs;

