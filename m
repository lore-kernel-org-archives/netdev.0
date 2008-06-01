From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Sun, 1 Jun 2008 02:46:22 +0100
Message-ID: <20080601014620.GG30769@solarflare.com>
References: <482F610D.2080108@sngx.net> <20080518003104.GK28241@solarflare.com> <482FBA09.80201@sngx.net> <483E0AAE.2020107@sngx.net> <20080528221118.63da4092.akpm@linux-foundation.org> <483EA2D1.8050603@sngx.net> <20080529154525.3916c7b5@core> <20080530151250.b44a119a.billfink@mindspring.com> <20080531131143.516ca56e@core> <20080531195702.0b879dd1.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	James Cammarata <jimi@sngx.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:37995 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754278AbYFABqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 21:46:48 -0400
Content-Disposition: inline
In-Reply-To: <20080531195702.0b879dd1.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
<snip>
> Yes, every individual Linux network administrator can re-create the
> wheel by devising their own scripts, but it makes much more sense
> to me to implement a simple general kernel mechanism once that could
> be used generically, than to have hundreds (or thousands) of Linux
> network administrators each having to do it themselves (perhaps
> multiple times if they have a variety of types of systems and types
> of NICs).

The ethtool interface is pretty generic, even if the names aren't.
Here's some Python code I just knocked up which demonstrates how
to get a set of named stats.  It shouldn't be terribly hard to
extend this to saving and subtracting stat sets.

Ben.

import array, fcntl, os, socket, struct

SIOCETHTOOL = 0x8946

ETH_GSTRING_LEN = 32
ETH_SS_STATS = 1

ETHTOOL_GDRVINFO = 0x00000003
ETHTOOL_GSTRINGS = 0x0000001b
ETHTOOL_GSTATS = 0x0000001d

def ethtool(sock, name, buf):
    ifreq = struct.pack('16sP', name, buf.buffer_info()[0])
    fcntl.ioctl(sock.fileno(), SIOCETHTOOL, ifreq)

def ethtool_gdrvinfo(sock, name):
    cmd = struct.pack('=I', ETHTOOL_GDRVINFO)
    buf = array.array('c', cmd)
    format = '=32s32s32s32s32x12xIIIII'
    buf.extend('\0' * struct.calcsize(format))
    ethtool(sock, name, buf)
    return dict(zip(['driver', 'version', 'fw_version', 'bus_info',
                     'n_priv_flags', 'n_stats', 'testinfo_len',
                     'eedump_len', 'regdump_len'],
                    struct.unpack(format, buf[len(cmd):])))

def ethtool_gstrings(sock, name, string_set, count):
    cmd = struct.pack('=II', ETHTOOL_GSTRINGS, string_set)
    buf = array.array('c', cmd)
    buf.extend('\0' * (4 + count * ETH_GSTRING_LEN))
    ethtool(sock, name, buf)
    def nth_string(buf, n):
        data = buf[12 + n * ETH_GSTRING_LEN : 12 + (n + 1) * ETH_GSTRING_LEN]
        return data.tostring().replace('\0', '')
    return [nth_string(buf, n) for n in range(count)]

def ethtool_gstats(sock, name, count):
    cmd = struct.pack('=I', ETHTOOL_GSTATS)
    buf = array.array('c', cmd)
    buf.extend('\0' * (4 + count * 8))
    ethtool(sock, name, buf)
    def nth_stat(buf, n):
        data = buf[8 + n * 8 : 8 + (n + 1) * 8]
        return struct.unpack('=Q', data)[0]
    return [nth_stat(buf, n) for n in range(count)]

if __name__ == '__main__':
    import sys
    name = sys.argv[1]
    sock = socket.socket()
    drvinfo = ethtool_gdrvinfo(sock, name)
    count = drvinfo['n_stats']
    print dict(zip(ethtool_gstrings(sock, name, ETH_SS_STATS, count),
                   ethtool_gstats(sock, name, count)))

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
