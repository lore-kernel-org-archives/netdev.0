From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC ] [1 of 4] IEEE802.11 Regulatory/Geographical Support for drivers
 - statement of project
Date: Sat, 03 Jun 2006 17:45:03 -0500
Message-ID: <448210EF.10103@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:21712 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751819AbWFCWpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 18:45:06 -0400
To: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As announced earlier in this list, I am working on providing kernel support for providing regulatory 
information to be used to set usable channels, max power, and other information needed by IEEE802.11 
drivers. The database will be maintained as a text file processed by a user-space daemon. I now have 
the complete system running on my machine. The full database and the user space daemon are available 
through a subversion repository at svn://lwfinger.dynalias.org/ide1/ieee80211_geo.

The details of the implementation are as follows:

1. A new routine, ieee80211_init_geo has been written that is called by a driver wishing to use this 
functionality. The arguments are an ieee80211_device, a two-character ISO3661 country code, and a 
flag that is true if the device is to be used outdoors. This new routine does the following:

   a) It establishes a default set of wireless parameters that will be supplied to the driver if the 
user space daemon is not running, if the daemon does not respond in a timely fashion, or if the 
daemon supplies data that do not pass rudimentary validity checks. The default data includes b/g 
channels 1 - 11 for indoor usage at a maximum power of 20 dBm (100 mW). At present, no 5 GHz 
channels are defined in the default set. This set of parameters should be legal everywhere.

   b) It then creates a new directory, '/proc/net/ieee80211_geo', and populates it with 2 files for 
communication with the daemon. The first, which is read by the daemon, contains the country and 
outdoor codes, and the second is for the the daemon to write the 'struct ieee80211_geo' data 
corresponding to the country and indoor/outdoor information passed from the kernel.

   c) It next spin loops for up to 1 second waiting for the user space daemon to respond. As noted 
earlier, if this loop times out, the default set is supplied.

   d) It then calls ieee80211_set_geo to load the channel data into the appropriate place in the 
ieee80211_device block, and returns the status to the driver.

2. The user-space daemon, which need not be run as root, does the following:

   a) It verifies that the text file containing the regulatory information is intact by assuming 
that the last line of the file contains the md5 sum for all of the file except for this last line. 
The scheme is certainly not tamper proof, but it ensures that whomever has modified the file has 
some technical skills. If the checksum is not correct, the program generates an appropriate error 
message and exits.

   b) It then process the country information consisting of a number pointing to an entry describing 
the 2.4 GHz band information, a second number pointing to the description of the 5 GHz bands, and a 
two-character country code.

   c) It then reads the groups that describe the allowed channels for the 2.4 GHz band and similar 
information for the 5 GHz bands and builds the tables in the form needed by the ieee80211_geo 
structure. Each input line consists of (a)the band identification characters "b", "bg", "a", or "h", 
(b) a channel range consisting of the starting and ending channels, (c) the number of channels 
between each stop (normally 1 for b/g and 4 for a), (d) the maximum eirp power for this channel in 
dBm, and (e) a set of flags for these channels. Flags currently implemented are for 802.11b only, 
for passive scanning, or for 802.11h rules. These data are checked to confirm that every group 
mentioned in the country section is indeed present, that the channels listed are appropriate for 
that band, and that there are no duplicate channels in any group. If there are any difficulties with 
the data the daemon aborts.

   d) It then daemonizes, unless the -F command-line switch was supplied.

   e) It then spins waiting for the existence of file '/proc/net/ieee80211_geo/country', which is 
the indication that the kernel is requesting data.

   f) It then reads the country and outdoor flag, finds the appropriate entries in its internal 
tables and writes the data back through the pseudo-file.in /proc. If the country code is unknown, a 
default dataset is supplied. The program then loops back to step e) and waits for the next driver load.

A segment of the country section of the data file is as follows (data are 2.4 GHz group, 5 GHz group 
ISO country name and English country name):

  0  0   AO      Angola, Republic of
  0  0   AI      Anguilla
  0  0   AG      Antigua and Barbuda
  9 12   AR      Argentina, Argentine Republic
  0  0   AM      Armenia
  0  0   AW      Aruba
  2  2   AU      Australia, Commonwealth of
  1  1   AT      Austria, Republic of
  0  0   AZ      Azerbaijan, Republic of

A couple of representative groups from the 2.4 GHz band are:

# Band  Ch_Range   Ch_Spacing  Power  Flags
#
bgGroup:  0             - Unspecified Country
#                       - Saudi Arabia (http://www.citc.sa)
#
bg        1 -  11       1       20      I
#
bgGroup: 1              - General European Union (EU)
#                       - India (Cetecom June 2 2005)
#
bg        1 -  13       1       20      B
#

Similarly, a couple of 5 GHz groups are:

aGroup: 0               - Unspecified (or unknown details for) Country
#                       - Bulgaria, Liechtenstein, Portugal, Romania, Slovakia, Spain
#
#
aGroup: 1               - General European Union (EU)
#                       - French Guiana and Reunion
#
h        36 -  48       4       23      I
h        52 -  64       4       23      IP
h       104 - 140       4       30      BP

I welcome your comments. Part 2 will show a debug dump of the converted database, Part 3 will 
present the patch needed to add the new routine to the ieee80211 routines, and Part 4 will show the 
patches needed to modify the bcm43xx driver to use the new routine..

Larry
